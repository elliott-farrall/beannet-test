{ ... }:

{
  flake.clan.machines."runner" = { config, ... }: {
    beannet.services."gatus" = {
      port = 8090;
    };

    services.traefik.dynamicConfigOptions = config.beannet.services."gatus".traefikConfig;

    services.gatus = {
      enable = true;

      settings = {
        web = { inherit (config.beannet.services."gatus") port; };

        endpoints = [
          config.beannet.services."authelia".gatusConfig
          config.beannet.services."ddns".gatusConfig
          config.beannet.services."gatus".gatusConfig
          config.beannet.services."glances".gatusConfig
          config.beannet.services."homepage".gatusConfig
          config.beannet.services."lldap".gatusConfig
          config.beannet.services."traefik".gatusConfig
        ];
      };
    };
  };
}
