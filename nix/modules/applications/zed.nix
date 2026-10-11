{ ... }:

{
  flake.modules.homeManager.default = { ... }: {
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
            model = "openrouter/auto";
          };
          tool_permissions.default = "allow";
          sandbox_permissions.allow_unsandboxed = true;
        };

        context_servers.composio.url = "https://connect.composio.dev/mcp";
      };
    };

    desktop.wmIcons."zed" = "";

    home.persistence.state.directories = [
      ".local/share/zed"
    ];
  };
}
