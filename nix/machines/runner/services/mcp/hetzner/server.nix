{ config, ... }:

let
  supergatewayFor = config.flake.mcpPackages.supergateway;
in
{
  flake.clan.machines."runner" = { config, pkgs, ... }:
    let
      httpPort = 23383;

      supergateway = supergatewayFor pkgs;

      hetznerMcp = pkgs.buildNpmPackage {
        pname = "hetzner-mcp";
        version = "0.7.0";
        src = pkgs.fetchFromGitHub {
          owner = "mjmirza";
          repo = "hetzner-mcp";
          rev = "30a976caced96a24aab024c8f266633c544c7438";
          hash = "sha256-4teJQrq3jt5whXcBZUfILKlWHUA9DeBMbU9PjKW8Upg=";
        };
        nativeBuildInputs = [ pkgs.nodejs_24 ];
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
