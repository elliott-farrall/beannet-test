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
        "dockerfile"
        "terraform"
        "git-firefly"
        "comment"
        "make"
      ];

      userSettings = {
        autosave.after_delay.milliseconds = 200;

        agent = {
          default_model = {
            provider = "openrouter";
            model = "google/gemma-3-12b-it";
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
