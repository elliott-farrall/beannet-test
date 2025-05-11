{ ... }:

let
  id = "tvqk3odd";
in
{
  flake.modules.homeManager."default" = { lib, pkgs, config, ... }: {
    options = {
      programs.zotero.enable = lib.mkEnableOption "Zotero";
    };

    config = lib.mkIf config.programs.zotero.enable {
      home.packages = with pkgs; [ zotero_7 ];

      xdg.configFile."zotero/profiles.ini".text = ''
        [General]
        StartWithLastProfile=1

        [Profile0]
        Name=default
        IsRelative=1
        Path=${id}.default
        Default=1
      '';

      wayland.windowManager.hyprland.settings.windowrulev2 = lib.mkIf config.wayland.windowManager.hyprland.enable [
        "float, class:(Zotero), title:(Progress)"
      ];

      programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
        "zotero" = "󰰸";
      };
    };
  };
}
