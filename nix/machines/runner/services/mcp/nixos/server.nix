{ ... }:

{
  flake.clan.machines."runner" = { config, pkgs, mcpPackages, ... }:
    let
      httpPort = 23382;

      inherit (mcpPackages) supergateway;

      entrypoint = pkgs.writeShellScript "entrypoint" ''
        exec ${pkgs.nodejs_24}/bin/node ${supergateway}/dist/index.js \
          --stdio "${pkgs.mcp-nixos}/bin/mcp-nixos" \
          --outputTransport streamableHttp \
          --port ${toString httpPort}
      '';

      image = pkgs.dockerTools.buildImage {
        name = "nixos-mcp";
        tag = "latest";
        copyToRoot = [
          pkgs.bash
          pkgs.cacert
          pkgs.mcp-nixos
          pkgs.nodejs_24
          supergateway
        ];
        config = {
          Entrypoint = [ "${entrypoint}" ];
          Env = [ "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
        };
      };
    in
    {
      virtualisation.oci-containers.containers.nixos = {
        image = "${image.imageName}:${image.imageTag}";
        imageFile = image;
        ports = [ "127.0.0.1:${toString httpPort}:${toString httpPort}" ];
        extraOptions = [ "--security-opt=no-new-privileges:true" ];
      };

      services.traefik.dynamicConfigOptions = {
        http.routers.nixos = {
          rule = "Host(`mcp.${config.beannet.domain}`) && PathPrefix(`/nixos`)";
          entryPoints = [ "websecure" ];
          service = "nixos";
          middlewares = [ "mcp-auth" "mcp-stripprefix" ];
          tls.certResolver = "cloudflare";
        };
        http.services.nixos.loadBalancer.servers = [
          { url = "http://127.0.0.1:${toString httpPort}"; }
        ];
      };
    };
}
