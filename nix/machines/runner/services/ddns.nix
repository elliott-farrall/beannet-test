{ ... }:

{
  flake.modules.nixos."machines/runner" = { config, ... }: {
    beannet.services."ddns" = {
      port = 8000;
    };

    services.traefik.dynamicConfigOptions = config.beannet.services."ddns".traefikConfig;

    services.ddns-updater = {
      enable = true;

      environment.CONFIG_FILEPATH = "%d/config.json";
    };
    systemd.services.ddns-updater.serviceConfig.LoadCredential = [
      "config.json:${config.clan.core.vars.generators."cloudflare".files."ddns-config".path}"
    ];

    clan.core.vars.generators."cloudflare" = {
      prompts."email" = {
        description = "cloudflare api email";
        persist = true;
      };
      prompts."key" = {
        description = "cloudflare api key";
        type = "hidden";
        persist = true;
      };
      prompts."zone" = {
        description = "cloudflare zone id";
        type = "hidden";
        persist = true;
      };

      files."ddns-config" = { };

      script = ''
        cat > $out/ddns-config <<EOF
        {
          "settings": [
            {
              "provider": "cloudflare",
              "zone_identifier": "$(cat $prompts/zone)",
              "domain": "${config.beannet.domain}",
              "ttl": 1,
              "email": "$(cat $prompts/email)",
              "key": "$(cat $prompts/key)"
            }
          ]
        }
        EOF
      '';
    };

    preservation.preserveAt."/persist".directories = [{ directory = "/var/lib/private/ddns-updater"; mode = "0700"; }];
  };
}
