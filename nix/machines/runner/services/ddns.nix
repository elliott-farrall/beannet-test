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

      files."ddns-config.json" = { };
      files."letsencrypt.env" = { };

      script = ''
        cat > $out/ddns-config.json <<EOF
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

        cat > $out/letsencrypt.env <<EOF
        CF_API_EMAIL=$(cat $prompts/email)
        CF_API_KEY=$(cat $prompts/key)
        EOF
      '';
    };

    environment.persistence.state.directories = [
      { directory = "/var/lib/private/ddns-updater"; mode = "0700"; }
    ];
  };
}
