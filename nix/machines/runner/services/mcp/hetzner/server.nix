{ ... }:

{
  flake.clan.machines."runner" = { config, pkgs, ... }:
    let
      httpPort = 23383;

      supergateway = pkgs.buildNpmPackage {
        pname = "supergateway";
        version = "4.1.0";
        src = pkgs.fetchFromGitHub {
          owner = "supercorp-ai";
          repo = "supergateway";
          rev = "a3ce8ba34c40f7565d1786e1dbd19621aca86093";
          hash = "sha256-oIO+EZ+9MFw5EmsPBDyxlfmPHJQ+7JhlH9qEep2Gv+s=";
        };
        nativeBuildInputs = [ pkgs.nodejs_24 ];
        npmDepsHash = "sha256-UxX19Sgp5sTAko/bC8+qZRpy6eCpYsxc/f3D+zuMGvs=";
        buildPhase = ''
          runHook preBuild
          npm run build
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r . $out
          runHook postInstall
        '';
      };

      hetznerMcp = pkgs.buildNpmPackage {
        pname = "hetzner-mcp";
        version = "0.7.0";
        src = pkgs.fetchFromGitHub {
          owner = "mjmirza";
          repo = "hetzner-mcp";
          rev = "30a976caced96a24aab024c8f266633c544c7438";
          hash = "sha256-4teJQrq3jt5whXcBZUfILKlWHUA9DeBMbU9PjKW8Upg=";
        };
        nativeBuildInputs = [ pkgs.nodejs_24 pkgs.pkg-config pkgs.python3 ];
        buildInputs = [ pkgs.libsecret ];
        npmDepsHash = "sha256-KBYqj19ynLGzmG9FBaHUPm3Xi5c1bTqSob7PEliSQsM=";
        buildPhase = ''
          runHook preBuild
          npm run build
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r . $out
          runHook postInstall
        '';
      };

      entrypoint = pkgs.writeShellScript "entrypoint" ''
        exec ${pkgs.nodejs_24}/bin/node ${supergateway}/dist/index.js \
          --stdio "${pkgs.nodejs_24}/bin/node ${hetznerMcp}/dist/index.js" \
          --outputTransport streamableHttp \
          --port ${toString httpPort}
      '';

      image = pkgs.dockerTools.buildImage {
        name = "hetzner-mcp";
        tag = "latest";
        copyToRoot = [
          pkgs.bash
          pkgs.cacert
          pkgs.nodejs_24
          hetznerMcp
          supergateway
        ];
        config = {
          Entrypoint = [ "${entrypoint}" ];
          Env = [ "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
        };
      };
    in
    {
      clan.core.vars.generators."hetzner" = {
        share = true;
        prompts."cloud-token" = {
          description = "Hetzner Cloud API token (create at https://console.hetzner.cloud → project → Security → API Tokens → Read/Write)";
          type = "hidden";
          persist = true;
        };
        files."env".secret = true;
        files."mcp-auth".secret = true;
        runtimeInputs = [ pkgs.openssl ];
        script = ''
          printf 'HETZNER_CLOUD_TOKEN=' > "$out/env"
          tr -d '\n' < "$prompts/cloud-token" >> "$out/env"
          printf '\n' >> "$out/env"
          printf 'TOKEN_HETZNER=' > "$out/mcp-auth"
          openssl rand -hex 32 >> "$out/mcp-auth"
        '';
      };

      systemd.services.mcp-auth.serviceConfig.EnvironmentFile = [
        config.clan.core.vars.generators."hetzner".files."mcp-auth".path
      ];

      virtualisation.oci-containers.containers.hetzner = {
        image = "${image.imageName}:${image.imageTag}";
        imageFile = image;
        environmentFiles = [ config.clan.core.vars.generators."hetzner".files."env".path ];
        ports = [ "127.0.0.1:${toString httpPort}:${toString httpPort}" ];
        extraOptions = [ "--security-opt=no-new-privileges:true" ];
      };

      services.traefik.dynamicConfigOptions = {
        http.routers.hetzner = {
          rule = "Host(`mcp.${config.beannet.domain}`) && PathPrefix(`/hetzner`)";
          entryPoints = [ "websecure" ];
          service = "hetzner";
          middlewares = [ "mcp-auth" "mcp-stripprefix" ];
          tls.certResolver = "cloudflare";
        };
        http.services.hetzner.loadBalancer.servers = [
          { url = "http://127.0.0.1:${toString httpPort}"; }
        ];
      };
    };
}
