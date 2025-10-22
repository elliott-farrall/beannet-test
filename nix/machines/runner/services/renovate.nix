{ ... }:

{
  flake.clan.machines."runner" = { lib, pkgs, config, ... }: {
    services.renovate = {
      enable = false; # FIXME - currently broken
      package = pkgs.renovate.overrideAttrs (attrs: rec {
        version = "39.264.0";

        src = pkgs.fetchFromGitHub {
          owner = "renovatebot";
          repo = "renovate";
          tag = version;
          hash = "sha256-ACeZ0RAIplcaRKyoEXFCwA/zu96CaLxTwjV0ok3TQ8w=";
        };

        pnpmDeps = pkgs.pnpm_10.fetchDeps {
          inherit (attrs) pname;
          inherit src version;
          fetcherVersion = 1;
          hash = "sha256-2F4vcdu2f0yh+hvs1WWM6MsWv2mmUUhzFVWN3BQvfNk=";
        };

        patches = (attrs.patches or [ ]) ++ [
          (pkgs.fetchpatch {
            # Nix support
            url = "https://github.com/renovatebot/renovate/pull/33991.diff";
            hash = "sha256-ENHTZ2MkD1TcOtNhNwCJfN/4FrYlGkfIeX/6wdfy7nY=";
          })
        ];
      });

      schedule = "*:0/30"; # Every 30 minutes
      credentials.RENOVATE_TOKEN = "/var/lib/renovate/token";

      runtimePackages = with pkgs; [ bash nix ];

      settings = {
        autodiscover = true;
        onboarding = false;
        allowedCommands = [ ".*" ];
      };
    };

    systemd.services.renovate-token =
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
