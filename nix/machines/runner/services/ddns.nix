{ ... }:

{
  flake.clan.machines."runner" = { config, ... }: {
    beannet.services."ddns" = {
      port = 8000;
    };

    services.traefik.dynamicConfigOptions = config.beannet.services."ddns".traefikConfig;

    services.ddns-updater = {
      enable = true;

      environment.CONFIG_FILEPATH = "%d/config.json";
    };
    systemd.services.ddns-updater.serviceConfig.LoadCredential = [
      "config.json:${config.clan.core.vars.generators."cloudflare".files."ddns-config.json".path}"
    ];

    environment.persistence.state.directories = [
      { directory = "/var/lib/private/ddns-updater"; mode = "0700"; }
    ];

    systemd.services.ddns-updater.serviceConfig = {
      IPAddressDeny = "any";
      IPAddressAllow = "localhost";
    };
  };
}
