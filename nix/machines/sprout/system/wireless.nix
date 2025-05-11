{ ... }:

{
  flake.clan.machines."sprout" = { config, ... }: {
    services.hostapd = {
      enable = true;

      radios."wlan" = {
        band = "5g";
        channel = 48; # ACS does not work
        countryCode = "GB-ENG";

        networks."wlan" = {
          ssid = "BeanNet";
          settings.bridge = "br";
          authentication.saePasswordsFile = config.clan.core.vars.generators."wifi".files."password".path;
        };
      };
    };

    clan.core.vars.generators."wifi" = {
      files."password" = { };

      prompts."password-input" = {
        description = "Wi-Fi password";
        type = "hidden";
        persist = false;
      };

      script = ''
        cat $prompts/password-input > $out/password
      '';
    };
  };
}
