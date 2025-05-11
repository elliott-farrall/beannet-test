{ ... }:

{
  flake.clan.machines."runner" = { pkgs, config, ... }: {
    beannet.services."ddns" = {
      port = 8000;
    };

    services.traefik.dynamicConfigOptions = config.beannet.services."ddns".traefikConfig;

    services.ddns-updater = {
      enable = true;

      environment.CONFIG_FILEPATH = "%d/config.json";
    };
    systemd.services.ddns-updater.serviceConfig.LoadCredential =
      let
        settings = [
          {
            provider = "cloudflare";
            zone_identifier = config.clan.core.vars.generators."cloudflare".files."zone".path;
            inherit (config.beannet) domain;
            ttl = 1;
            email = config.clan.core.vars.generators."cloudflare".files."email".path;
            key = config.clan.core.vars.generators."cloudflare".files."key".path;
          }
        ];
      in
      [ "config.json:${pkgs.writeText "config.json" (builtins.toJSON { inherit settings; })}" ];

    clan.core.vars.generators."cloudflare" = {
      files."email" = { };
      files."key" = { };
      files."zone" = { };

      prompts."email-input" = {
        description = "cloudflare api email";
        type = "hidden";
        persist = false;
      };
      prompts."key-input" = {
        description = "cloudflare api key";
        type = "hidden";
        persist = false;
      };
      prompts."zone-input" = {
        description = "cloudflare zone id";
        type = "hidden";
        persist = false;
      };

      script = ''
        cat $prompts/email-input > $out/email
        cat $prompts/key-input > $out/key
        cat $prompts/zone-input > $out/zone
      '';
    };
  };
}
