{ ... }:

{
  flake.clan.machines."runner" = { config, ... }: {
    beannet.services."glances" = {
      port = 61208;
    };

    services.traefik.dynamicConfigOptions = config.beannet.services."glances".traefikConfig;

    services.glances = {
      enable = true;
      inherit (config.beannet.services."glances") port;
    };
  };
}
