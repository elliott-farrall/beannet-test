{ inputs, ... }:

{
  flake.clan.machines."runner" = { lib, pkgs, config, ... }:
    let
      hermesProtonpass = pkgs.runCommand "hermes-protonpass" { } ''
        mkdir -p $out
        cp -r ${inputs.hermes-protonpass}/* $out/
        chmod -R u+w $out
        patch -d $out -p1 < ${./patches/hermes-protonpass-nixos-pass-cli.patch}
      '';

      # Mail / Drive / Calendar plugin (droolyai/hermes-proton). Backed by
      # roman-16/proton-cli, which authenticates via SRP login (password + 2FA)
      # saved as a session. Credentials come from the user's Proton Pass
      # Identity vault item, resolved below — so the login can be automated.
      # The repo now keeps the plugin under plugins/proton/, so we point $out
      # at that subdirectory to satisfy hermes-agent's extraPlugins contract
      # (plugin.yaml + __init__.py at the package root).
      hermesProton = pkgs.runCommand "hermes-proton" { } ''
        mkdir -p $out
        cp -r ${inputs.hermes-proton}/plugins/proton/* $out/
        chmod -R u+w $out
      '';

      # Ensure the proton-cli config/session dir is owned by hermes (the
      # persistence mount creates it as root), so the auth service can write the
      # session and consume the one-shot .proton-verified token. Runs as root.
      protonAuthPermsScript = pkgs.writeShellScript "hermes-proton-auth-perms" ''
        mkdir -p /var/lib/hermes/.config/proton-cli
        chown -R hermes:hermes /var/lib/hermes/.config
        chmod 700 /var/lib/hermes/.config /var/lib/hermes/.config/proton-cli
      '';

      # Automate `proton account login` from the credentials stored in a Proton
      # Pass item. Resolves username/password + the current TOTP code via
      # pass-cli (authenticated with the existing PAT), then logs into proton-cli.
      # Runs as the hermes user so the session lands in
      # /var/lib/hermes/.config/proton-cli/ (persisted).
      protonAuthScript = pkgs.writeShellScript "hermes-proton-auth" ''
        set -eu
        item_ref="$1"
        : "''${PROTON_PASS_PERSONAL_ACCESS_TOKEN:?PROTON_PASS_PERSONAL_ACCESS_TOKEN is not set}"
        export PROTON_PASS_PERSONAL_ACCESS_TOKEN
        # The scoped agent token requires a reason header on every call.
        export PROTON_PASS_AGENT_REASON="proton account login automation"

        # Establish a pass-cli session from the PAT (idempotent), with one
        # logout/recovery retry before giving up on the field fetches below.
        pass-cli login >/dev/null 2>&1 || true
        if ! pass-cli info >/dev/null 2>&1; then
          pass-cli logout --force >/dev/null 2>&1 || true
          pass-cli login >/dev/null 2>&1
        fi

        user="$(pass-cli item view -- "$item_ref/email")"
        pass="$(pass-cli item view -- "$item_ref/password")"

        # One-shot solved-captcha token, if the user wrote one (see skill).
        # Consumed here and removed, so the next run needs a fresh token.
        verified_file="/var/lib/hermes/.config/proton-cli/.proton-verified"
        verified_arg=""
        if [ -s "$verified_file" ]; then
          verified_arg="--verified $(tr -d '\n' < "$verified_file")"
          # Consume the one-shot token; a deletion failure must never block the
          # login (e.g. a root-owned leftover file).
          rm -f "$verified_file" 2>/dev/null || true
        fi

        login_proton() {
          # Fetch the current TOTP code immediately before login (30s validity);
          # extract the 6-digit code so labels/JSON wrappers never leak through.
          totp="$(pass-cli item totp -- "$item_ref" | grep -oE '[0-9]{6}' | head -1)"
          [ -n "$totp" ] || { echo "proton-auth: no TOTP code for $item_ref" >&2; exit 1; }
          # --no-input: never hang on a captcha. If Proton asks for human
          # verification, proton prints the page + a retry token to stderr/stdout
          # (captured in the journal). Solve it on any device, write the token to
          # $verified_file, and restart the service.
          printf '%s' "$pass" | proton account login \
            --user "$user" --password-stdin --totp "$totp" --no-input $verified_arg
        }

        # Retry once in case the TOTP code rolls over between fetch and login.
        login_proton || login_proton
      '';

    in
    {
      imports = [ inputs.hermes-agent.nixosModules.default ];

      beannet.services."hermes" = {
        hostname = "127.0.0.1";
        port = 9119;
        # Identity vault item holding the Proton account login credentials
        # (email / password / TOTP), used to automate `proton account login`.
        # NOTE: the share ID here is the one the scoped agent token resolves the
        # item under (verified via `pass-cli item view`); it differs from the
        # share ID shown in the user's full-account view.
        protonItem = "pass://_xEmSMJtla7fEotP05dydQvVLB1H73PMKY5JNT-G6KiAT8ND8vyTlGdL1Zu-pLwTFlcFETPs4M0LbAulJ4aN9g==/r1Jn61vQo7EbNeaGoJPYh7eGSAyriwTbofPpFN1WzsDtdwnwPC6Ig4WbY1cBH5ROPMty0muGaEPl-s-R7BhC-A==";
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
            protonpass.enabled = true;
          };

          model = {
            provider = "openrouter";
            default = "openrouter/auto";
          };
        };

        environmentFiles = [
          config.clan.core.vars.generators."openrouter".files."env".path
          config.clan.core.vars.generators."proton".files."env".path
          config.clan.core.vars.generators."hermes".files."env".path
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

          # Proton Pass CLI skill and command references from upstream
          # (github:tohuw/proton-pass-skill).
          "skills/proton-pass/SKILL.md" = builtins.readFile (inputs.skill-proton-pass + "/SKILL.md");
          "skills/proton-pass/references/commands.md" = builtins.readFile (inputs.skill-proton-pass + "/references/commands.md");
          "skills/proton-pass/references/bootstrap.md" = builtins.readFile (inputs.skill-proton-pass + "/references/bootstrap.md");
          "skills/proton-pass/references/dedupe.md" = builtins.readFile (inputs.skill-proton-pass + "/references/dedupe.md");
          "skills/proton-pass/references/agent-guard.md" = builtins.readFile (inputs.skill-proton-pass + "/references/agent-guard.md");
        };

        mcpServers = { };
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
          "/var/lib/hermes/.hermes/memories"
          "/var/lib/hermes/.hermes/cron"
          "/var/lib/hermes/.hermes/backups"
          "/var/lib/hermes/.hermes/installs"
          # proton-cli session/config (Mail, Calendar, Drive) — persists the
          # interactive `proton account login` session across reboots.
          "/var/lib/hermes/.config/proton-cli"
        ];
      };

      environment.persistence.data.directories = [
        "/var/lib/hermes/.hermes/sessions"
      ];

      # Keep the proton-cli (Mail/Drive/Calendar) session fresh by logging in
      # from the Proton Pass Identity item holding the account credentials.
      systemd.services.hermes-proton-auth = lib.mkIf (config.beannet.services."hermes".protonItem != "") {
        description = "Establish/refresh the proton-cli session from Proton Pass credentials";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        path = [
          pkgs.proton-pass-cli
          pkgs.proton-cli
          pkgs.coreutils
          pkgs.gnugrep
          pkgs.gnused
        ];
        # Isolated pass-cli session dir so we never clash with Hermes' own.
        environment = {
          PROTON_PASS_SESSION_DIR = "/var/lib/hermes/.hermes/protonpass-session-auth";
        };
        serviceConfig = {
          Type = "oneshot";
          User = "hermes";
          Group = "hermes";
          ExecStartPre = "+${protonAuthPermsScript}";
          ExecStart = "${protonAuthScript} ${config.beannet.services."hermes".protonItem}";
          # Existing Proton Pass PAT, used to resolve the credentials item.
          EnvironmentFile = [ config.clan.core.vars.generators."proton".files."env".path ];
        };
      };

      systemd.timers."hermes-proton-auth" = lib.mkIf (config.beannet.services."hermes".protonItem != "") {
        description = "Periodically refresh the proton-cli session";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnBootSec = "2min";
          OnUnitActiveSec = "12h";
          Unit = "hermes-proton-auth.service";
        };
      };

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
