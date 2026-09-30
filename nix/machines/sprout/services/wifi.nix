{ ... }:

{
  flake.clan.machines."sprout" = { config, ... }: {
    services.hostapd = {
      enable = false; # Not needed when using mesh

      radios."wlan" = {
        countryCode = "GB";
        band = "5g";
        channel = 36; # ACS does not work

        networks."wlan" = {
          ssid = "BeanNet";
          authentication = {
            mode = "wpa3-sae-transition";
            saePasswordsFile = config.clan.core.vars.generators."wifi".files."sae-passwords".path;
            wpaPasswordFile = config.clan.core.vars.generators."wifi".files."wpa-password".path;
          };
          settings.bridge = "br";
        };
      };
    };

    clan.core.vars.generators."wifi" = {
      share = true;

      prompts."password" = {
        description = "WiFi password";
        type = "hidden";
        persist = true;
      };

      files."wpa-password" = { secret = true; };
      files."sae-passwords" = { secret = true; };

      script = ''
        PASSWORD=$(cat $prompts/password)
        echo "$PASSWORD" > $out/wpa-password
        echo "$PASSWORD" > $out/sae-passwords
      '';
    };
  };
}
