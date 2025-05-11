{ ... }:

{
  flake.modules.nixos."machines/runner" = { lib, pkgs, config, ... }:
    let
      generate-token = pkgs.stdenv.mkDerivation {
        name = "generate-token";

        buildInputs = with pkgs; [ makeWrapper ];

        src = pkgs.fetchFromGitHub {
          owner = "Nastaliss";
          repo = "get-github-app-pat";
          rev = "main";
          hash = "sha256-pNYpIlsPmrAgKnHcZwFGtf9sDUZW5VNbeoTr5cILNfc=";
        };

        installPhase = ''
          mkdir -p $out/bin
          cp $src/generate_github_access_token.sh $out/bin/generate
          wrapProgram $out/bin/generate \
            --prefix PATH : ${lib.makeBinPath (with pkgs; [ curl jq openssl ])}
        '';
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

        schedule = "*:0/30"; # Every 30 minutes
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
        before = [ "renovate.service" ];
        requiredBy = [ "renovate.service" ];

        script = ''
          export APP_ID=$(cat ${config.clan.core.vars.generators."renovate".files."app-id".path})
          export APP_INSTALLATION_ID=$(cat ${config.clan.core.vars.generators."renovate".files."app-installation-id".path})
          export SIGNING_KEY_PATH=${config.clan.core.vars.generators."renovate".files."private-key".path}

          mkdir -p $(dirname ${config.services.renovate.credentials.RENOVATE_TOKEN})
          ${generate-token}/bin/generate > ${config.services.renovate.credentials.RENOVATE_TOKEN}
          chmod 0600 ${config.services.renovate.credentials.RENOVATE_TOKEN}
        '';
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
