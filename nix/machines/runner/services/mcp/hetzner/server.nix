{ ... }:

{
  flake.clan.machines."runner" = { config, pkgs, ... }:
    let
      httpPort = 23383;

      supergateway = pkgs.buildNpmPackage {
        pname = "supergateway";
        version = "4.2.0-rc.1";
        src = pkgs.fetchFromGitHub {
          owner = "supercorp-ai";
          repo = "supergateway";
          rev = "dc9066fa1ea3d9bc8f65f38a5be5d0bbd1085f4b";
          hash = "sha256-P5RPgssyqarvGdgYPaEmGxrC0jZPpOxSCeT4Jif/X9I=";
        };
        nativeBuildInputs = [ pkgs.nodejs_24 ];
        npmDepsHash = "sha256-ix1WNLU3QaTn0uAGXei4RDdpEhe6bx5OtDZhZBYVUcc=";
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
        npmDepsHash = "sha256-wnQBxirXla/DEfg+rRwUOwwA3gnL0ZqYlvIZT4kdsF0=";
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
          --stateful \
          --apiKey "$COMPOSIO_TOKEN" \
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
        files."composio".secret = true;
        runtimeInputs = [ pkgs.openssl ];
        script = ''
          printf 'HETZNER_CLOUD_TOKEN=' > "$out/env"
          tr -d '\n' < "$prompts/cloud-token" >> "$out/env"
          printf '\n' >> "$out/env"
          printf 'COMPOSIO_TOKEN=' > "$out/composio"
          openssl rand -hex 32 >> "$out/composio"
        '';
      };

      virtualisation.oci-containers.containers.hetzner = {
        image = "${image.imageName}:${image.imageTag}";
        imageFile = image;
        environmentFiles = [
          config.clan.core.vars.generators."hetzner".files."env".path
          config.clan.core.vars.generators."hetzner".files."composio".path
        ];
        ports = [ "127.0.0.1:${toString httpPort}:${toString httpPort}" ];
        extraOptions = [ "--security-opt=no-new-privileges:true" ];
      };

      services.traefik.dynamicConfigOptions = {
        http.routers.hetzner = {
          rule = "Host(`mcp.${config.beannet.domain}`) && PathPrefix(`/hetzner`)";
          entryPoints = [ "websecure" ];
          service = "hetzner";
          middlewares = [ "mcp-stripprefix" ];
          tls.certResolver = "cloudflare";
        };
        http.services.hetzner.loadBalancer.servers = [
          { url = "http://127.0.0.1:${toString httpPort}"; }
        ];
      };
    };
}
