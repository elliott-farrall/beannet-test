{ ... }:

{
  flake.modules.homeManager.default = { config, lib, ... }: {
    programs.zed-editor = {
      enable = true;
      mutableUserSettings = false;
      enableMcpIntegration = true;

      extensions = [
        "log"
        "nix"
        "rlsp-yaml"
        "dockerfile"
        "terraform"
        "comment"
      ];

      userSettings = {
        autosave.after_delay.milliseconds = 200;

        agent = {
          default_model = {
            provider = "openrouter";
            model = "qwen/qwen3.7-flash";
          };
          tool_permissions.default = "allow";
          sandbox_permissions.allow_unsandboxed = true;
        };

        context_servers.composio.url = "https://connect.composio.dev/mcp";

        agent_servers."OpenCode" = {
          type = "custom";
          command = lib.getExe config.programs.opencode.package;
          args = [ "acp" ];
        };
      };
    };

    desktop.wmIcons."zed" = "";

    home.persistence.state.directories = [
      ".local/share/zed"
    ];
  };
}
