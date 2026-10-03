{ ... }:

{
  flake.clan.machines."runner" = { lib, config, ... }: {
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
          http.routers."traefik" = {
            rule = "Host(`traefik.${config.beannet.domain}`)";
            service = lib.mkForce "api@internal";
            entryPoints = [ "websecure" ];
            middlewares = [ "auth" ];
            tls.certResolver = "cloudflare";
          };
        }
      ];

      staticConfigOptions = {
        api = {
          insecure = false;
          dashboard = true;
        };

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
          dnsChallenge = {
            provider = "cloudflare";
            resolvers = [ "1.1.1.1:53" "8.8.8.8:53" ];
          };
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
