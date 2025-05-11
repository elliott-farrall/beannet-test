{ ... }:

{
  flake.clan.machines."runner" = { lib, config, ... }: {
    beannet.services."homepage" = {
      port = 8082;
    };

    services.traefik.dynamicConfigOptions = config.beannet.services."homepage".traefikConfig;

    services.homepage-dashboard = {
      enable = true;
      listenPort = config.beannet.services."homepage".port;
      allowedHosts = lib.concatStringsSep "," [
        config.beannet.services."homepage".domain
        config.beannet.domain
      ];

      widgets = [
        {
          greeting = {
            text = "BeanNet";
            text_size = "4xl";
          };
        }
        {
          glances = {
            inherit (config.beannet.services."glances") url;
            version = 4;
            cpu = true;
            mem = true;
            cputemp = true;
            uptime = true;
            disk = "/";
          };
        }
      ];

      services = [
        {
          "Network" = [
            {
              "Traefik" = {
                icon = "traefik.png";
                inherit (config.beannet.services."traefik") href;
                description = "Traefik Dashboard";
                siteMonitor = config.beannet.services."traefik".url;
                widget = {
                  type = "traefik";
                  inherit (config.beannet.services."traefik") url;
                };
              };
            }
            {
              "LLDAP" = {
                icon = "ldap-account-manager.png";
                inherit (config.beannet.services."lldap") href;
                description = "LLDAP Dashboard";
                siteMonitor = config.beannet.services."lldap".url;
              };
            }
            {
              "Gatus" = {
                icon = "gatus.png";
                inherit (config.beannet.services."gatus") href;
                description = "Gatus Dashboard";
                siteMonitor = config.beannet.services."gatus".url;
                widget = {
                  type = "gatus";
                  inherit (config.beannet.services."gatus") url;
                };
              };
            }
            {
              "DDNS" = {
                icon = "ddns-updater.png";
                inherit (config.beannet.services."ddns") href;
                description = "DDNS Updater";
                siteMonitor = config.beannet.services."ddns".url;
              };
            }
          ];
        }
        {
          "Machines" = [
            {
              "Runner" = {
                href = "https://glances.beannet.io";
              };
            }
          ];
        }
      ];

      bookmarks = [
        {
          "Internet" = [
            {
              "Hetzner" = [
                {
                  abbr = "HC";
                  href = "https://console.hetzner.com";
                }
              ];
            }
            {
              "Cloudflare" = [
                {
                  abbr = "CF";
                  href = "https://dash.cloudflare.com";
                }
              ];
            }
            {
              "Mullvad" = [
                {
                  abbr = "MV";
                  href = "https://mullvad.net";
                }
              ];
            }
          ];
        }
        {
          "Usenet" = [
            {
              "NewsHosting" = [
                {
                  abbr = "NH";
                  href = "https://newshosting.com";
                }
              ];
            }
            {
              "NZBGeek" = [
                {
                  abbr = "NZBG";
                  href = "https://nzbgeek.info";
                }
              ];
            }
          ];
        }
      ];

      settings = {
        title = "beannet";
        hideVersion = true;
      };
    };
  };
}
