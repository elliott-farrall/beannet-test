{ ... }:

{
  flake.modules.homeManager."programs/kitty" = { lib, pkgs, config, ... }:
    let
      # TODO - Move to overlay
      package = pkgs.symlinkJoin {
        name = "kitty";
        paths = [ pkgs.kitty ];
        postBuild = ''
          install -v ${pkgs.kitty}/share/applications/kitty.desktop $out/share/applications/kitty.desktop
          substituteInPlace $out/share/applications/kitty.desktop \
            --replace "Name=kitty" "Name=Kitty"
        '';
      };
    in
    {
      programs.kitty = {
        enable = true;
        inherit package;
        settings.confirm_os_window_close = 0;
      };

      home.sessionVariables.TERMINAL = "${package}/bin/kitty";

      stylix.targets.kitty.enable = false;

      programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
        "kitty" = "󰆍";
      };
    };
}
