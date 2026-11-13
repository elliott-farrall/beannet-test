{ inputs, ... }:

{
  flake.clan.machines."runner" = { lib, pkgs, config, ... }:
    let
      jimAvatar = pkgs.runCommand "jim-avatar.png"
        {
          nativeBuildInputs = [ pkgs.librsvg ];
        } ''
        rsvg-convert -w 256 -h 256 -o $out ${inputs.raccoon-emoji}
      '';
    in
    {
      imports = [ inputs.openclaw.nixosModules.openclaw-gateway ];

      nixpkgs.overlays = [ inputs.openclaw.overlays.default ];

      beannet.services."openclaw" = {
        hostname = "127.0.0.1";
        port = 18789;
      };

      services.traefik.dynamicConfigOptions = lib.mkMerge [
        config.beannet.services."openclaw".traefikConfig
        {
          http.routers."openclaw".middlewares = lib.mkForce [ ];
        }
      ];

      services.openclaw-gateway = {
        enable = true;
        inherit (config.beannet.services."openclaw") port;

        execStartPre = [
          "+${pkgs.systemd}/bin/systemd-tmpfiles --create --prefix ${config.services.openclaw-gateway.stateDir}"
          "+${pkgs.coreutils}/bin/install -m 0644 -o ${config.services.openclaw-gateway.user} -g ${config.services.openclaw-gateway.group} ${jimAvatar} ${config.services.openclaw-gateway.stateDir}/workspace/avatars/jim.png"
        ];

        servicePath = [ pkgs.gh pkgs.rtk ];

        environmentFiles = [
          config.clan.core.vars.generators."openrouter".files."env".path
          config.clan.core.vars.generators."composio".files."env".path
          config.clan.core.vars.generators."openclaw".files."env".path
          config.clan.core.vars.generators."github-token".files."env".path
        ];

        config = {
          gateway = {
            mode = "local";
            publicOrigin = config.beannet.services."openclaw".href;
            trustedProxies = [ config.beannet.services."openclaw".hostname ];
            auth.token = "\${OPENCLAW_GATEWAY_TOKEN}";
          };

          agents.entries.main = {
            name = "Jim";
            identity = {
              name = "Jim";
              avatar = "avatars/jim.png";
            };
            model.primary = "openrouter/qwen/qwen3.7-flash";
            modelPolicy.allow = [ "openrouter/qwen/qwen3.7-flash" ];
            thinkingDefault = "medium";
          };

          plugins = {
            load.paths = [ inputs.rtk-openclaw ];
            entries.rtk-rewrite = {
              enabled = true;
              config = {
                enabled = true;
                verbose = false;
              };
            };
            entries.device-pair.config.publicUrl = config.beannet.services."openclaw".href;
          };

          mcp.servers.composio = {
            url = "https://connect.composio.dev/mcp";
            transport = "streamable-http";
            headers = {
              "x-consumer-api-key" = "\${COMPOSIO_API_KEY}";
            };
          };
        };
      };

      systemd.tmpfiles.rules = [
        "d ${config.services.openclaw-gateway.stateDir}/workspace/avatars 0750 ${config.services.openclaw-gateway.user} ${config.services.openclaw-gateway.group} - -"
      ];

      environment.persistence.data.directories = [ config.services.openclaw-gateway.stateDir ];

      clan.core.vars.generators."github-token" = {
        files."env".secret = true;
        prompts."token" = {
          description = "GitHub personal access token for Jim (repo, workflow, read:org, gist)";
          type = "hidden";
          persist = true;
        };
        script = ''
          printf 'GH_TOKEN=' > "$out/env"
          tr -d '\n' < "$prompts/token" >> "$out/env"
        '';
      };

      clan.core.vars.generators."openclaw" = {
        files."env".secret = true;
        runtimeInputs = with pkgs; [ openssl coreutils ];
        script = ''
          printf 'OPENCLAW_GATEWAY_TOKEN=' > "$out/env"
          openssl rand -hex 32 | tr -d '\n' >> "$out/env"
          printf '\n' >> "$out/env"
        '';
      };
    };
}
