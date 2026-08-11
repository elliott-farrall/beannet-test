{ ... }:

{
  flake.modules.homeManager.default =
    { config, pkgs, ... }:
    let
      nixos-skill = pkgs.fetchFromGitHub {
        owner = "marceloeatworld";
        repo = "nixos-ai-skill";
        rev = "c9b25a6a9e5b9ad9f84cc8753d0021a5a251d4d8";
        hash = "sha256-97qJ1yvmXdPOHIARY7ZRdCnOAfqc5PpdN/Mg8SRTTfg=";
      };

      terraform-skill = "${pkgs.fetchFromGitHub {
        owner = "antonbabenko";
        repo = "terraform-skill";
        rev = "0a3a4a66e99001347d36a41e10260a825be3ab62";
        hash = "sha256-utKu3sueu6SdhjmtRa+Osg761YPwdQa6IPhceZsgsn8=";
      }}/skills/terraform-skill";

      farmage = "${pkgs.fetchFromGitHub {
        owner = "farmage";
        repo = "opencode-skills";
        rev = "364fd372e452eb41ebf781349d201eecaab5b900";
        hash = "sha256-zO57OaZY25kg0LtQqqeqiYwrTIoiiSekBmXir/2IH80=";
      }}/.opencode/skills";

      azure-devops = "${pkgs.fetchFromGitHub {
        owner = "microsoft";
        repo = "azure-devops-skills";
        rev = "844a1f6f5202aa920ce5b1be95c056d529d63ded";
        hash = "sha256-luKzdZ0CFhgEn2ntIC91eY8Xt8JChAmrto2Uz4munsw=";
      }}/.github/skills";
    in
    {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;

        package = pkgs.writeShellApplication {
          name = "opencode";
          runtimeInputs = with pkgs; [ opencode nodejs ];
          text = ''
            OPENROUTER_API_KEY=$(< ${config.sops.secrets."openrouter/api-key".path})
            export OPENROUTER_API_KEY
            # codegraph ships its own node binary linked against libstdc++
            LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
            export LD_LIBRARY_PATH
            exec opencode "$@"
          '';
        };

        settings = {
          enabled_providers = [ "openrouter" ];
          plugin = [ "oh-my-opencode-slim" "opencode-mem" "opencode-direnv" ];

          agent.build.disable = true;
          agent.plan.disable = true;

          provider.openrouter.options.baseURL = "http://127.0.0.1:8787/v1"; # Headroom Proxy

          permission = {
            read = "allow";
            glob = "allow";
            grep = "allow";
            list = "allow";
            edit = "allow";
            write = "allow";
            webfetch = "allow";
            websearch = "allow";
            lsp = "allow";

            bash = {
              # Deny catastrophic/irreversible operations
              "rm -rf /*" = "deny";
              "rm -rf ~*" = "deny";
              "dd *" = "deny";
              "mkfs*" = "deny";
              # Deny imperative nix/system management — use clan machines instead
              "nixos-rebuild *" = "deny";
              "nix-env *" = "deny";
              "nix profile *" = "deny";
              "home-manager switch*" = "deny";
              # Require approval for deployments, service control, and destructive git ops
              "sudo *" = "ask";
              "clan machines*" = "ask";
              "systemctl *" = "ask";
              "git push*" = "ask";
              "rm *" = "ask";
              # Allow everything else: reads, nix build/eval, git commits, treefmt, etc.
              "*" = "allow";
            };

            # Azure DevOps: write tools suffixed _write or wiki_upsert_* / repo_create_*
            "*_write" = "ask";
            "wiki_upsert_*" = "ask";
            "repo_create_*" = "ask";
            # Terraform Cloud: create/update/delete/attach/detach operations
            "create_*" = "ask";
            "update_*" = "ask";
            "delete_*" = "ask";
            "attach_*" = "ask";
            "detach_*" = "ask";
            # GitHub: file/repo mutations and social actions
            "push_*" = "ask";
            "merge_*" = "ask";
            "fork_*" = "ask";
            "add_*" = "ask";
            "star_*" = "ask";
            "unstar_*" = "ask";
            "assign_*" = "ask";
            "request_*" = "ask";
            "dismiss_*" = "ask";
            "manage_*" = "ask";
            "mark_*" = "ask";
            "actions_run_trigger" = "ask";
          };
        };

        skills = {
          nixos = nixos-skill;
          terraform = terraform-skill;
          typescript-pro = "${farmage}/typescript-pro";
          python-pro = "${farmage}/python-pro";
          devops-engineer = "${farmage}/devops-engineer";
          cloud-architect = "${farmage}/cloud-architect";
          terraform-engineer = "${farmage}/terraform-engineer";
          monitoring-expert = "${farmage}/monitoring-expert";
          microservices-architect = "${farmage}/microservices-architect";
          api-designer = "${farmage}/api-designer";
          secure-code-guardian = "${farmage}/secure-code-guardian";
          code-reviewer = "${farmage}/code-reviewer";
          debugging-wizard = "${farmage}/debugging-wizard";
          atlassian-mcp = "${farmage}/atlassian-mcp";
          ado-boards-backlog = "${azure-devops}/boards-backlog-summary";
          ado-boards-my-work = "${azure-devops}/boards-my-work";
          ado-boards-team-work = "${azure-devops}/boards-team-active-work";
          ado-boards-work-item = "${azure-devops}/boards-work-item-summary";
          ado-pipelines = "${azure-devops}/pipelines-build-summary";
          ado-security-alerts = "${azure-devops}/security-alert-review";
          ado-work-iterations = "${azure-devops}/work-iterations";
        };

        context = ''
          # NixOS environment

          You are running on NixOS. Read this before editing files or running
          commands.

          ## Read-only paths

          `/nix/store` and all paths derived from it are immutable. Many files
          under `~/.config`, `~/.local`, `/etc`, and `/run` are either symlinks
          into the nix store or bind-mounted — do not attempt to write to them.
          If a path appears to be a symlink, check its target with `readlink -f`
          before editing.

          ## Impermanence

          The root filesystem is ephemeral and reset on reboot. Persistent data
          lives under `/pst`:

          | Path                      | Purpose    |
          | ------------------------- | ---------- |
          | `/pst/data/home/<user>/`  | User data  |
          | `/pst/state/home/<user>/` | User state |
          | `/pst/log/home/<user>/`   | User logs  |

          Home directory paths like `~/.config/foo` may be symlinks into one of
          these locations — follow the symlink to find the real file.

          ## Running tools

          Not all tools are globally installed. Use `comma` or `nix shell` to
          run tools ephemerally without installing them:

          ```sh
          , <tool>                                   # comma (finds package automatically)
          nix shell nixpkgs#<pkg> --command <tool>   # explicit nix shell
          ```

          ## Further reading

          - NixOS manual: https://nixos.org/manual/nixos/stable/
          - home-manager manual: https://nix-community.github.io/home-manager/
          - Impermanence module: https://github.com/nix-community/impermanence
          - opencode docs: https://opencode.ai/docs
        '';
      };

      xdg.configFile."opencode/oh-my-opencode-slim.json".text = builtins.toJSON {
        "\$schema" = "https://unpkg.com/oh-my-opencode-slim@latest/oh-my-opencode-slim.schema.json";
        preset = "openrouter";
        presets.openrouter = {
          orchestrator = {
            model = "openrouter/qwen/qwen3.7-plus";
            skills = [ "*" ];
            mcps = [ "*" ];
          };
          oracle = {
            model = "openrouter/qwen/qwen3-max";
            skills = [ "simplify" ];
            mcps = [ ];
          };
          librarian = {
            model = "openrouter/deepseek/deepseek-v4-flash";
            mcps = [ "context7" ];
          };
          explorer = {
            model = "openrouter/deepseek/deepseek-v4-flash";
          };
          designer = {
            model = "openrouter/moonshotai/kimi-k2.7-code";
          };
          fixer = {
            model = "openrouter/deepseek/deepseek-v4-flash";
          };
        };
      };

      stylix.targets.opencode.enable = false; # Managed by Catppuccin

      xdg.configFile."opencode/opencode-mem.jsonc".text = builtins.toJSON {
        autoCaptureEnabled = true;
        webServerEnabled = false;
        memory.defaultScope = "project";
        opencodeProvider = "openrouter";
        opencodeModel = "qwen/qwen3-30b-a3b-instruct-2507";
      };

      home.persistence.state.directories = [ ".local/share/opencode" ];
      home.persistence.data.directories = [ ".opencode-mem" ];
    };
}
