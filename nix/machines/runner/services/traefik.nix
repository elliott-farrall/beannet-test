{ ... }:

{
  flake.modules.nixos."machines/runner" = { lib, config, ... }: {
    beannet.services."traefik" = {
      port = 8080;
    };

    services.traefik = {
      enable = true;
      environmentFiles = [ config.clan.core.vars.generators."cloudflare".files."letsencrypt.env".path ];

      dynamicConfigOptions = lib.mkMerge [
        config.beannet.services."traefik".traefikConfig
        {
          http.routers."main" = {
            rule = "Host(`${config.beannet.domain}`)";
            service = "homepage";
          };
        }
      ];

      staticConfigOptions = {
        api.insecure = true;

        entryPoints."web" = {
          address = ":${toString config.beannet.ports.http}";
          asDefault = true;
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        entryPoints."websecure" = {
          address = ":${toString config.beannet.ports.https}";
          asDefault = true;
          http.tls.certResolver = "cloudflare";
          http.middlewares = [ "auth" ];
        };
        entryPoints."auth" = {
          address = ":${toString config.beannet.ports.auth}";
          http.tls.certResolver = "cloudflare";
        };

        certificatesResolvers."cloudflare".acme = {
          storage = "${config.services.traefik.dataDir}/acme.json";
          dnsChallenge.provider = "cloudflare";
        };

        log.level = "INFO";
      };
    };

    environment.persistence.state.directories = [
      config.services.traefik.dataDir
    ];

    networking.firewall.allowedTCPPorts = with config.beannet.ports; [ http https auth ];
  };
}
