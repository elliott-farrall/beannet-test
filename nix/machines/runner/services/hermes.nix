{ inputs, ... }:

{
  flake.clan.machines."runner" = { lib, pkgs, config, ... }:
    let
      apiServerPort = 8642;
    in
    {
      imports = [ inputs.hermes-agent.nixosModules.default ];

      beannet.services."hermes" = {
        hostname = "127.0.0.1";
        port = 9119;
      };

      # The Hermes dashboard has DNS-rebinding protection: when bound to
      # 127.0.0.1 it rejects requests whose Host header is not 127.0.0.1.
      # It also validates the WebSocket Origin header against the bind address.
      # Rewrite both so Traefik can proxy the public subdomain while the
      # backend sees loopback. Authelia still runs first because the middleware
      # chain is evaluated left-to-right; Clan VPN clients bypass Authelia via
      # an access-control rule while public clients keep the SSO gate.
      services.traefik.dynamicConfigOptions = lib.mkMerge [
        config.beannet.services."hermes".traefikConfig
        {
          http.routers."hermes".middlewares = [ "auth" "hermes-host" ];
          http.middlewares."hermes-host".headers.customRequestHeaders = {
            Host = "127.0.0.1";
            Origin = "http://127.0.0.1:${toString config.beannet.services."hermes".port}";
          };

          # The api_server platform (used by Hermes Relay / desktop peers) runs
          # on its own loopback port. Expose it publicly on a separate subdomain
          # and also under the dashboard domain on the API paths, so the web
          # dashboard (which expects the API on the same origin) works in the
          # mobile app's webview.
          http.routers."hermes-api" = {
            rule = "Host(`hermes-api.${config.beannet.domain}`)";
            service = "hermes-api";
          };
          http.routers."hermes-api-v1" = {
            rule = "Host(`hermes.${config.beannet.domain}`) && PathPrefix(`/v1`)";
            service = "hermes-api";
          };
          http.routers."hermes-api-sessions" = {
            rule = "Host(`hermes.${config.beannet.domain}`) && PathPrefix(`/api/sessions`)";
            service = "hermes-api";
          };
          http.routers."hermes-api-jobs" = {
            rule = "Host(`hermes.${config.beannet.domain}`) && PathPrefix(`/api/jobs`)";
            service = "hermes-api";
          };
          http.routers."hermes-api-platforms" = {
            rule = "Host(`hermes.${config.beannet.domain}`) && PathPrefix(`/api/platforms`)";
            service = "hermes-api";
          };
          http.routers."hermes-api-cron" = {
            rule = "Host(`hermes.${config.beannet.domain}`) && PathPrefix(`/api/cron`)";
            service = "hermes-api";
          };
          http.services."hermes-api".loadBalancer.servers = [
            { url = "http://127.0.0.1:${toString apiServerPort}"; }
          ];
        }
      ];

      services.hermes-agent = {
        enable = true;

        backend = {
          mode = "dashboard";
          host = "127.0.0.1";
          port = config.beannet.services."hermes".port;
        };

        workingDirectory = "/var/lib/hermes/workspace";

        settings = {
          dashboard.public_url = config.beannet.services."hermes".href;

          platforms.api_server = {
            enabled = true;
            extra = {
              host = "127.0.0.1";
              port = apiServerPort;
            };
          };

          model = {
            provider = "openrouter";
            # Cost-optimised main model. Gemini Flash is dramatically cheaper than
            # Claude Sonnet while still capable enough for routine agent work.
            default = "~google/gemini-flash-latest";
          };
          provider_routing = {
            # Prefer the cheapest OpenRouter provider for each request.
            sort = "price";
          };
          fallback_providers = [
            # DeepSeek Chat is a cheap, capable backup if Gemini Flash fails.
            { provider = "openrouter"; model = "deepseek/deepseek-chat"; }
          ];
          openrouter = {
            min_coding_score = 0.65;
          };
          # Offload side tasks to free OpenRouter models. If a free tier is
          # rate-limited, Hermes falls back to the main model for that call.
          auxiliary = {
            vision = { provider = "openrouter"; model = "google/gemini-2.0-flash-exp:free"; };
            title_generation = { provider = "openrouter"; model = "meta-llama/llama-3.1-8b-instruct:free"; };
            compression = { provider = "openrouter"; model = "qwen/qwen-2.5-72b-instruct:free"; };
            approval = { provider = "openrouter"; model = "meta-llama/llama-3.1-8b-instruct:free"; };
            skills_hub = { provider = "openrouter"; model = "meta-llama/llama-3.1-8b-instruct:free"; };
            mcp = { provider = "openrouter"; model = "meta-llama/llama-3.1-8b-instruct:free"; };
          };
        };

        environmentFiles = [
          config.clan.core.vars.generators."openrouter".files."env".path
          config.clan.core.vars.generators."hermes-api-key".files."env".path
          config.clan.core.vars.generators."hermes-dashboard-auth".files."env".path
        ];

        # MCP servers will be wired here once the exact list is decided.
        # They will be wrapped behind Atlassian's mcp-compressor before being
        # handed to Hermes.
        mcpServers = { };
      };

      environment.persistence.state.directories = [
        "/var/lib/hermes"
      ];

      # The upstream module relies on activation/tmpfiles to create the working
      # directory. On the first deploy there is a race with systemd, causing the
      # service to fail once with CHDIR before restarting. Ensure the directory
      # exists as root before ExecStart runs.
      systemd.services.hermes-agent.serviceConfig.ExecStartPre = lib.mkBefore [
        "+${pkgs.writeShellScript "hermes-mkdir-wd" ''
          mkdir -p /var/lib/hermes/workspace
          chown hermes:hermes /var/lib/hermes/workspace
        ''}"
      ];
      systemd.services.hermes-backend.serviceConfig.ExecStartPre = lib.mkBefore [
        "+${pkgs.writeShellScript "hermes-backend-mkdir-wd" ''
          mkdir -p /var/lib/hermes/workspace
          chown hermes:hermes /var/lib/hermes/workspace
        ''}"
      ];

      networking.firewall.extraCommands = ''
        iptables -A nixos-fw -p tcp --dport ${toString config.beannet.services."hermes".port} -j nixos-fw-refuse
      '';
    };
}
