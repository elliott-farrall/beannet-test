{ inputs, ... }:

{
  flake.clan.machines."runner" = { lib, pkgs, config, ... }:
    let
      dashboardAuth = pkgs.writeShellScript "hermes-dashboard-auth" ''
        env_file=/var/lib/hermes/.hermes/.env
        touch "$env_file"
        if ! grep -q '^HERMES_DASHBOARD_BASIC_AUTH_USERNAME=' "$env_file"; then
          printf 'HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin\n' >> "$env_file"
        fi
        if ! grep -q '^HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=' "$env_file"; then
          printf 'HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=' >> "$env_file"
          tr -d '\n' < ${config.clan.core.vars.generators."ldap".files."password".path} >> "$env_file"
          printf '\n' >> "$env_file"
        fi
        chown hermes:hermes "$env_file"
      '';

      # hermes-proton wraps proton-cli to expose Mail, Drive and Calendar as
      # agent tools. The plugin lives in the plugins/proton subdirectory of the
      # repo, so extract it into a standalone package.
      hermesProton = pkgs.runCommand "hermes-proton" { } ''
        mkdir -p $out
        cp -r ${inputs.hermes-proton}/plugins/proton/* $out/
      '';

      # hermes-protonpass resolves Hermes credentials from a Proton Pass vault.
      # The repo root is the plugin package.
      hermesProtonpass = pkgs.runCommand "hermes-protonpass" { } ''
        mkdir -p $out
        cp -r ${inputs.hermes-protonpass}/* $out/
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
          hermesProton
          hermesProtonpass
        ];

        backend = {
          mode = "dashboard";
          host = config.beannet.services."hermes".hostname;
          port = config.beannet.services."hermes".port;
        };

        settings = {
          dashboard.public_url = config.beannet.services."hermes".href;

          plugins.enabled = [ "proton" "protonpass" ];

          provider_routing.sort = "price";
          openrouter.min_coding_score = 0.65;

          model = {
            provider = "openrouter";
            default = "~google/gemini-flash-latest";
          };
          auxiliary = {
            vision = {
              provider = "openrouter";
              model = "google/gemini-2.0-flash-exp:free";
            };
            title_generation = {
              provider = "openrouter";
              model = "meta-llama/llama-3.1-8b-instruct:free";
            };
            compression = {
              provider = "openrouter";
              model = "qwen/qwen-2.5-72b-instruct:free";
            };
            approval = {
              provider = "openrouter";
              model = "meta-llama/llama-3.1-8b-instruct:free";
            };
            skills_hub = {
              provider = "openrouter";
              model = "meta-llama/llama-3.1-8b-instruct:free";
            };
            mcp = {
              provider = "openrouter";
              model = "meta-llama/llama-3.1-8b-instruct:free";
            };
          };
          fallback_providers = [
            {
              provider = "openrouter";
              model = "deepseek/deepseek-chat";
            }
          ];
        };

        environmentFiles = [
          config.clan.core.vars.generators."openrouter".files."env".path
        ];

        hermesHomeFiles."SOUL.md" = ''
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

        mcpServers = { };
      };

      environment.systemPackages = [ pkgs.proton-cli ];

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
          # proton-cli session (holds the logged-in Proton session and keys)
          "/var/lib/hermes/.config/proton-cli"
        ];
      };

      environment.persistence.data.directories = [
        "/var/lib/hermes/.hermes/sessions"
      ];

      systemd.services.hermes-backend.serviceConfig.ExecStartPre = lib.mkBefore [
        "+${dashboardAuth}"
      ];
    };
}
