{ ... }:

{
  flake.clan.machines."runner" = {
    services.headscale = {
      enable = true;
      address = "127.0.0.1";
      port = 8080;
      settings = {
        server_url = "https://headscale.bean.directory";
        dns = {
          magic_dns = false;
          override_local_dns = false;
        };
      };
    };

    services.traefik.dynamicConfigOptions = {
      http.routers."headscale" = {
        rule = "Host(`headscale.bean.directory`)";
        service = "headscale";
        tls.certResolver = "cloudflare";
      };
      http.services."headscale".loadBalancer.servers = [
        { url = "http://127.0.0.1:8080"; }
      ];
    };
  };
}
