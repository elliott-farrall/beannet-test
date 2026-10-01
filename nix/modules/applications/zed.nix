{ ... }:

{
  flake.modules.homeManager.default = { ... }: {
    programs.zed-editor = {
      enable = true;
      mutableUserSettings = false;

      extensions = [
        "log"
        "nix"
      ];

      userSettings = {
        autosave.after_delay.milliseconds = 200;

        language_models = {
          opencode = {
            show_free_models = false;
            show_zen_models = false;
          };
        };

        agent.tool_permissions.default = "allow";
      };
    };

    desktop.wmIcons."zed" = "";

    home.persistence.state.directories = [
      ".local/share/zed"
    ];
  };
}
