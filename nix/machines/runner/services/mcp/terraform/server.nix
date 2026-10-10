{ ... }:

{
  flake.clan.machines."runner" = { config, pkgs, ... }:
    let
      httpPort = 23384;

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
          --stdio "${pkgs.terraform-mcp-server}/bin/terraform-mcp-server" \
          --outputTransport streamableHttp \
          --port ${toString httpPort}
      '';

      image = pkgs.dockerTools.buildImage {
        name = "terraform-mcp";
        tag = "latest";
        copyToRoot = [
          pkgs.bash
          pkgs.cacert
          pkgs.nodejs_24
          pkgs.terraform-mcp-server
          supergateway
        ];
        config = {
          Entrypoint = [ "${entrypoint}" ];
          Env = [ "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
        };
      };
    in
    {
      clan.core.vars.generators."terraform-mcp" = {
        files."env".secret = true;
        runtimeInputs = [ pkgs.openssl ];
        script = ''
          printf 'TOKEN_TERRAFORM=' > "$out/env"
          openssl rand -hex 32 >> "$out/env"
        '';
      };

      systemd.services.mcp-auth.serviceConfig.EnvironmentFile = [
        config.clan.core.vars.generators."terraform-mcp".files."env".path
      ];

      virtualisation.oci-containers.containers.terraform = {
        image = "${image.imageName}:${image.imageTag}";
        imageFile = image;
        environmentFiles = [ config.clan.core.vars.generators."terraform".files."env".path ];
        ports = [ "127.0.0.1:${toString httpPort}:${toString httpPort}" ];
        extraOptions = [ "--security-opt=no-new-privileges:true" ];
      };

      services.traefik.dynamicConfigOptions = {
        http.routers.terraform = {
          rule = "Host(`mcp.${config.beannet.domain}`) && PathPrefix(`/terraform`)";
          entryPoints = [ "websecure" ];
          service = "terraform";
          middlewares = [ "mcp-auth" "mcp-stripprefix" ];
          tls.certResolver = "cloudflare";
        };
        http.services.terraform.loadBalancer.servers = [
          { url = "http://127.0.0.1:${toString httpPort}"; }
        ];
      };
    };
}
