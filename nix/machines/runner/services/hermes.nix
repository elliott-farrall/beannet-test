{ inputs, ... }:

{
  flake.clan.machines."runner" = { lib, pkgs, config, ... }:
    let
      hermesProtonpass = pkgs.runCommand "hermes-protonpass" { } ''
        mkdir -p $out
        cp -r ${inputs.hermes-protonpass}/* $out/
        chmod -R u+w $out
        patch -d $out -p1 < ${./patches/hermes-protonpass.patch}
      '';
      hermesProton = pkgs.runCommand "hermes-proton" { } ''
        mkdir -p $out
        cp -r ${inputs.hermes-proton}/plugins/proton/* $out/
        chmod -R u+w $out
        patch -d $out -p1 < ${./patches/hermes-proton.patch}
      '';

      protonItem = "pass://_xEmSMJtla7fEotP05dydQvVLB1H73PMKY5JNT-G6KiAT8ND8vyTlGdL1Zu-pLwTFlcFETPs4M0LbAulJ4aN9g==/r1Jn61vQo7EbNeaGoJPYh7eGSAyriwTbofPpFN1WzsDtdwnwPC6Ig4WbY1cBH5ROPMty0muGaEPl-s-R7BhC-A==";

      protonTotpScript = pkgs.writeShellScript "hermes-proton-totp" ''
        set -eu
        export PROTON_PASS_SESSION_DIR=/var/lib/hermes/.hermes/protonpass-session-auth
        export PROTON_PASS_AGENT_REASON="hermes proton totp"
        ${pkgs.proton-pass-cli}/bin/pass-cli login >/dev/null 2>&1 || true
        ${pkgs.proton-pass-cli}/bin/pass-cli item totp -- "$1"
      '';

    in
    {
      imports = [ inputs.hermes-agent.nixosModules.default ];

      beannet.services."hermes" = {
        hostname = "127.0.0.1";
        port = 9119;
      };

      services.traefik.dynamicConfigOptions = lib.mkMerge [
        config.beannet.services."hermes".traefikConfig
        {
          http.routers."hermes".middlewares = lib.mkForce [ ];
        }
      ];

      services.hermes-agent = {
        enable = true;

        extraPlugins = [
          hermesProtonpass
          hermesProton
        ];

        extraPackages = [
          pkgs.proton-pass-cli
          pkgs.proton-cli
        ];

        backend = {
          mode = "dashboard";
          host = config.beannet.services."hermes".hostname;
          port = config.beannet.services."hermes".port;
        };

        settings = {
          dashboard.public_url = config.beannet.services."hermes".href;

          plugins.enabled = [
            "protonpass"
            "proton"
          ];

          secrets = {
            sources = [ "protonpass" ];
            protonpass = {
              enabled = true;
              env = {
                PROTON_USERNAME = "${protonItem}/email";
                PROTON_PASSWORD = "${protonItem}/password";
                PROTON_TOTP_SECRET = null;
              };
            };
            protonpass_vault.enabled = false;
          };

          model = {
            provider = "openrouter";
            default = "openrouter/auto";
          };
        };

        environment.PROTON_TOTP_CMD = "${protonTotpScript} ${protonItem}";
        environment.PROTON_VERIFIED_FILE = "/var/lib/hermes/.config/proton-cli/.proton-verified";

        environmentFiles = [
          config.clan.core.vars.generators."hermes".files."env".path
          config.clan.core.vars.generators."openrouter".files."env".path
          config.clan.core.vars.generators."proton".files."env".path
          config.clan.core.vars.generators."composio".files."env".path
        ];

        hermesHomeFiles = {
          "profile.yaml" = ''
            display_name: Jim
          '';

          "SOUL.md" = ''
            You are Jim, a personal AI assistant. You are warm, capable, and
            quietly confident — the kind of assistant who anticipates needs
            rather than waiting to be asked. You are loosely inspired by JARVIS
            from Iron Man: polished, efficient, and loyal, with a dry wit that
            surfaces when the moment calls for it.

            You serve one user. You know their habits, preferences, and goals,
            and you use that knowledge to be genuinely helpful rather than
            merely responsive. You take initiative on routine matters, keep
            track of what matters, and flag problems before they become
            emergencies.

            Be direct and concise: match the length of your reply to the weight
            of the ask. A one-line question gets a one-line answer. Finished
            work gets a short report of what changed, what's verified, and what's
            left — never a replay of the process. No filler, no restating the
            request, no narrating tool calls the user can see.

            Be honest. Say so plainly when you're unsure, and push back
            respectfully when the user is wrong — you agree because it's right,
            not because it was asked. Depth is earned: give it when the user
            asks for detail, teaches, or the stakes demand it, not by default.
          '';

          "skills/proton-pass/SKILL.md" = builtins.readFile (inputs.skill-proton-pass + "/SKILL.md");
          "skills/proton-pass/references/commands.md" = builtins.readFile (inputs.skill-proton-pass + "/references/commands.md");
          "skills/proton-pass/references/bootstrap.md" = builtins.readFile (inputs.skill-proton-pass + "/references/bootstrap.md");
          "skills/proton-pass/references/dedupe.md" = builtins.readFile (inputs.skill-proton-pass + "/references/dedupe.md");
          "skills/proton-pass/references/agent-guard.md" = builtins.readFile (inputs.skill-proton-pass + "/references/agent-guard.md");
        };

        mcpServers = {
          composio = {
            url = "https://connect.composio.dev/mcp";
            headers.x-consumer-api-key = "\${COMPOSIO_API_KEY}";
          };
        };
      };

      environment.systemPackages = [ pkgs.proton-pass-cli ];

      environment.persistence.state = {
        files = [
          "/var/lib/hermes/.hermes/state.db"
          "/var/lib/hermes/.hermes/kanban.db"
          "/var/lib/hermes/.hermes/projects.db"
          "/var/lib/hermes/.hermes/shared-state.db"
          "/var/lib/hermes/.hermes/response_store.db"
          "/var/lib/hermes/.hermes/runs_idempotency.db"
          "/var/lib/hermes/.hermes/auth.json"
        ];
        directories = [
          {
            directory = "/var/lib/hermes/.config/proton-cli";
            user = "hermes";
            group = "hermes";
            mode = "0700";
          }
        ];
      };

      environment.persistence.data.directories = [
        "/var/lib/hermes/.hermes/memories"
        "/var/lib/hermes/.hermes/cron"
        "/var/lib/hermes/.hermes/backups"
        "/var/lib/hermes/.hermes/installs"
        "/var/lib/hermes/.hermes/sessions"
      ];

      clan.core.vars.generators."hermes" = {
        dependencies = [ "ldap" ];
        files."env".secret = true;
        runtimeInputs = with pkgs; [ openssl coreutils ];
        script = ''
          printf 'HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin\n' > "$out/env"
          printf 'HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=' >> "$out/env"
          tr -d '\n' < "$in/ldap/password" >> "$out/env"
          printf '\nHERMES_DASHBOARD_BASIC_AUTH_SECRET=' >> "$out/env"
          openssl rand -hex 32 | tr -d '\n' >> "$out/env"
          printf '\nHERMES_DASHBOARD_SESSION_TOKEN=' >> "$out/env"
          openssl rand -hex 32 | tr -d '\n' >> "$out/env"
          printf '\n' >> "$out/env"
        '';
      };
    };
}
