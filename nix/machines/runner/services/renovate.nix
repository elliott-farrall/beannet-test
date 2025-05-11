{ ... }:

{
  clan.machines."runner" = { lib, pkgs, config, ... }:
    let
      create-token = pkgs.writeShellScript "create_token" ''
        set -euo pipefail

        b64enc() { openssl enc -base64 -A | tr '+/' '-_' | tr -d '='; }
        NOW=$(date +%s)

        HEADER=$(printf '{
            "alg": "RS256",
            "exp": %d,
            "iat": %d,
            "iss": "adyxax",
            "kid": "0001",
            "typ": "JWT"
        }' "$((NOW+10))" "''${NOW}" | jq -r -c .)

        PAYLOAD=$(printf '{
            "exp": %s,
            "iat": %s,
            "iss": %s
        }' "$((NOW + 10 * 59))" "$((NOW - 10))" "''${GITHUB_APP_ID}" | jq -r -c .)

        SIGNED_CONTENT=$(printf '%s' "''${HEADER}" | b64enc).$(printf '%s' "''${PAYLOAD}" | b64enc)
        SIG=$(printf '%s' "''${SIGNED_CONTENT}" | \
            openssl dgst -binary -sha256 -sign <(printf "%s" "''${GITHUB_APP_PRIVATE_KEY}") | b64enc)
        JWT=$(printf '%s.%s' "''${SIGNED_CONTENT}" "''${SIG}")

        curl -s --location --request POST \
            "https://api.github.com/app/installations/''${GITHUB_APP_INSTALLATION_ID}/access_tokens" \
            --header "Authorization: Bearer $JWT" \
            --header 'Accept: application/vnd.github+json' \
            --header 'X-GitHub-Api-Version: 2022-11-28' | jq -r '.token'
      '';
    in
    {
      services.renovate = {
        enable = true;
        package = pkgs.renovate.overrideAttrs (attrs: {
          patches = (attrs.patches or [ ]) ++ [
            (pkgs.fetchpatch {
              #TODO - Remove when [PR](https://github.com/renovatebot/renovate/pull/33991) is merged
              url = "https://github.com/renovatebot/renovate/pull/33991.diff";
              hash = "sha256-AELURThHctKcJcXrbXD7QBN6uXTdLqm5piA8mJ4gr+4=";
            })
          ];
        });

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
          export GITHUB_APP_ID=$(cat ${config.sops.secrets."renovate_app-id".path})
          export GITHUB_APP_INSTALLATION_ID=$(cat ${config.sops.secrets."renovate_app-installation-id".path})
          export GITHUB_APP_PRIVATE_KEY=$(cat ${config.sops.secrets."renovate_private-key".path})

          mkdir -p $(dirname ${config.services.renovate.credentials.RENOVATE_TOKEN})
          ${create-token} > ${config.services.renovate.credentials.RENOVATE_TOKEN}
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
    };
}
