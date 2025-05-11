{ ... }:

{
  flake.modules.homeManager."default" = { lib, config, ... }: {
    config = lib.mkIf config.programs.obsidian.enable {
      xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "obsidian.desktop" [
        "text/markdown"
      ];

      programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
        "obsidian" = "";
      };
    };
  };
}
