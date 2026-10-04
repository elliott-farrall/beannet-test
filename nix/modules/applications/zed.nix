{ ... }:

{
  flake.modules.homeManager.default = { ... }: {
    programs.zed-editor = {
      enable = true;
      mutableUserSettings = false;

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

        language_models = {
          opencode = {
            show_free_models = false;
            show_zen_models = false;
          };
        };

        agent = {
          tool_permissions.default = "allow";
          sandbox_permissions.allow_unsandboxed = true;
        };
      };
    };

    desktop.wmIcons."zed" = "";

    home.persistence.state.directories = [
      ".local/share/zed"
    ];
  };
}
