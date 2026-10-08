{ inputs, ... }:

{
  flake.clan.machines."runner" = { lib, pkgs, config, ... }:
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

        backend = {
          mode = "dashboard";
          host = config.beannet.services."hermes".hostname;
          port = config.beannet.services."hermes".port;
        };

        workingDirectory = "/var/lib/hermes/workspace";

        settings = {
          dashboard.public_url = config.beannet.services."hermes".href;

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

        mcpServers = { };
      };

      environment.persistence.state.directories = [
        "/var/lib/hermes"
      ];

      # Inject the Hermes dashboard basic-auth credentials (reusing the LLDAP
      # admin password) into ~/.hermes/.env before the services start. The
      # module's activation rewrites .env from environmentFiles, so this runs as
      # ExecStartPre to append the auth vars each start.
      systemd.services.hermes-agent.serviceConfig.ExecStartPre = lib.mkBefore [
        "+${pkgs.writeShellScript "hermes-mkdir-wd" ''
          mkdir -p /var/lib/hermes/workspace
          chown hermes:hermes /var/lib/hermes/workspace
        ''}"
        "+${pkgs.writeShellScript "hermes-dashboard-auth" ''
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
        ''}"
      ];
      systemd.services.hermes-backend.serviceConfig.ExecStartPre = lib.mkBefore [
        "+${pkgs.writeShellScript "hermes-backend-mkdir-wd" ''
          mkdir -p /var/lib/hermes/workspace
          chown hermes:hermes /var/lib/hermes/workspace
        ''}"
        "+${pkgs.writeShellScript "hermes-backend-dashboard-auth" ''
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
        ''}"
      ];
    };
}
