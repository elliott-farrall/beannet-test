{ ... }:

{
  flake.clan.machines."runner" = { lib, pkgs, config, ... }:
    let
      src = pkgs.fetchFromGitHub {
        owner = "Nastaliss";
        repo = "get-github-app-pat";
        rev = "main";
        hash = "";
      };
    in
    {
      services.renovate = {
        enable = true;
        # package = pkgs.renovate.overrideAttrs (attrs: {
        #   patches = (attrs.patches or [ ]) ++ [
        #     (pkgs.fetchpatch {
        #       #TODO - Remove when [PR](https://github.com/renovatebot/renovate/pull/33991) is merged
        #       url = "https://github.com/renovatebot/renovate/pull/33991.diff";
        #       hash = "sha256-AELURThHctKcJcXrbXD7QBN6uXTdLqm5piA8mJ4gr+4=";
        #     })
        #   ];
        # });

        schedule = "*:0/5"; # Every 5 minutes
        credentials.RENOVATE_TOKEN = "/var/lib/renovate/token";

        runtimePackages = with pkgs; [ bash nix ];

        settings = {
          autodiscover = true;
          onboarding = false;
          allowedCommands = [ ".*" ];
        };
      };

      systemd.services.renovate-token = {
        description = "Generate Renovate Token";
        script = ''
          export APP_ID=$(cat ${config.clan.core.vars.generators."renovate".files."app-id".path})
          export APP_INSTALLATION_ID=$(cat ${config.clan.core.vars.generators."renovate".files."app-installation-id".path})
          export SIGNING_KEY_PATH=$(cat ${config.clan.core.vars.generators."renovate".files."private-key".path})

          mkdir -p $(dirname ${config.services.renovate.credentials.RENOVATE_TOKEN})
          ${src}/generate_github_access_token.sh > ${config.services.renovate.credentials.RENOVATE_TOKEN}
        '';
        path = with pkgs; [ openssl curl jq ];
      };

      systemd.services.renovate = {
        after = [ "renovate-token.service" ];
        requires = [ "renovate-token.service" ];

        serviceConfig = {
          # baseDir is owned by root
          User = lib.mkForce "root";
          Group = lib.mkForce "root";
        };
      };

      clan.core.vars.generators."renovate" = {
        prompts."app-id" = {
          description = "renovate app id";
          type = "hidden";
          persist = true;
        };
        prompts."app-installation-id" = {
          description = "renovate app installation id";
          type = "hidden";
          persist = true;
        };
        prompts."private-key" = {
          description = "renovate private key";
          type = "multiline-hidden";
          persist = true;
        };
      };
    };
}
