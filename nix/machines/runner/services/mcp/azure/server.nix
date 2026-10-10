{ ... }:

{
  flake.clan.machines."runner" = { config, lib, pkgs, mcpPackages, ... }:
    let
      httpPort = 23385;

      inherit (mcpPackages) supergateway;

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
