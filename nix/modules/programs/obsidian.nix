{ ... }:

{
  flake.modules.homeManager."programs/obsidian" = { lib, config, ... }: {
    xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "obsidian.desktop" [
      "text/markdown"
    ];

    programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
      "obsidian" = "";
    };
  };
}
