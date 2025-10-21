{ ... }:

let
  id = "tvqk3odd";
in
{
  flake.modules.homeManager."programs/zotero" = { lib, pkgs, config, ... }: {
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

    wayland.windowManager.hyprland.settings.windowrulev2 = lib.mkIf config.wayland.windowManager.hyprland.enable [
      "float, class:(Zotero), title:(Progress)"
    ];
  };
}
