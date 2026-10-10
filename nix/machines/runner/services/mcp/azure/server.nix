{ ... }:

{
  flake.clan.machines."runner" = { config, lib, pkgs, ... }:
    let
      httpPort = 23385;

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

      entrypoint = pkgs.writeShellScript "entrypoint" ''
        exec ${pkgs.nodejs_24}/bin/node ${supergateway}/dist/index.js \
          --stdio "${pkgs.azure-mcp}/bin/azure-mcp server start" \
          --outputTransport streamableHttp \
          --port ${toString httpPort}
      '';

      image = pkgs.dockerTools.buildImage {
        name = "azure-mcp";
        tag = "latest";
        copyToRoot = [
          pkgs.bash
          pkgs.cacert
          pkgs.nodejs_24
          pkgs.azure-mcp
          pkgs.icu
          pkgs.openssl
          supergateway
        ];
        config = {
          Entrypoint = [ "${entrypoint}" ];
          Env = [
            "HOME=/tmp"
            "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            "LD_LIBRARY_PATH=${lib.makeLibraryPath [pkgs.icu pkgs.openssl]}"
          ];
        };
      };
    in
    {
      clan.core.vars.generators."azure-mcp" = {
        files."env".secret = true;
        runtimeInputs = [ pkgs.openssl ];
        script = ''
          printf 'TOKEN_AZURE=' > "$out/env"
          openssl rand -hex 32 >> "$out/env"
        '';
      };

      systemd.services.mcp-auth.serviceConfig.EnvironmentFile = [
        config.clan.core.vars.generators."azure-mcp".files."env".path
      ];

      virtualisation.oci-containers.containers.azure = {
        image = "${image.imageName}:${image.imageTag}";
        imageFile = image;
        environmentFiles = [ config.clan.core.vars.generators."azure".files."env".path ];
        ports = [ "127.0.0.1:${toString httpPort}:${toString httpPort}" ];
        extraOptions = [ "--security-opt=no-new-privileges:true" ];
      };

      services.traefik.dynamicConfigOptions = {
        http.routers.azure = {
          rule = "Host(`mcp.${config.beannet.domain}`) && PathPrefix(`/azure`)";
          entryPoints = [ "websecure" ];
          service = "azure";
          middlewares = [ "mcp-auth" "mcp-stripprefix" ];
          tls.certResolver = "cloudflare";
        };
        http.services.azure.loadBalancer.servers = [
          { url = "http://127.0.0.1:${toString httpPort}"; }
        ];
      };
    };
}
