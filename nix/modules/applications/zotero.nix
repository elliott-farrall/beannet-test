{ ... }:

let
  id = "tvqk3odd";
in
{
  flake.modules.homeManager.default = { lib, pkgs, config, ... }: {
    options = {
      applications.zotero.enable = pkgs.lib.mkEnableOption "the Zotero application";
    };

    config = lib.mkIf config.applications.zotero.enable {
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

      desktop.wmIcons."zotero" = "󰰸";

      wayland.windowManager.hyprland.settings.windowrule = lib.mkIf config.wayland.windowManager.hyprland.enable [
        "float 1, match:class Zotero match:title Progress"
      ];
    };
  };
}
