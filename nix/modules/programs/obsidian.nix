{ ... }:

{
  flake.modules.homeManager."default" = { lib, pkgs, config, ... }: {
    options = {
      programs.obsidian.enable = lib.mkEnableOption "Obsidian";
    };

    config = lib.mkIf config.programs.obsidian.enable {
      home.packages = with pkgs; [
        obsidian
      ];

      xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "obsidian.desktop" [
        "text/markdown"
      ];

      programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
        "obsidian" = "";
      };
    };
  };
}
