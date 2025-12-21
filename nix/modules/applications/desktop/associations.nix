{ ... }:

{
  flake.modules.homeManager.default = { lib, config, ... }: {
    options = {
      desktop.wmIcons = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        description = "Icons for window manager workspace indicators.";
        default = { };
      };
    };

    config = {
      xdg.mimeApps.enable = true;
      xdg.dataFile."applications/mimeapps.list".enable = false; # Fixes conflict with applications symlink

      programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable config.desktop.wmIcons;
    };
  };
}
