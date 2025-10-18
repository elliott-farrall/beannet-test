{ ... }:

{
  flake.modules.homeManager."programs/vivaldi" = { lib, pkgs, config, ... }:
    let
      # TODO - Move to overlay
      package = pkgs.vivaldi.overrideAttrs (attrs: {
        postInstall = (attrs.postInstall or "") + ''
          wrapProgram $out/bin/vivaldi \
            --add-flags "\''${WAYLAND_DISPLAY:+--ozone-platform=wayland}"
        '';
      });
    in
    {
      home.packages = [ package ];

      home.sessionVariables.BROWSER = lib.getExe package;

      xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "vivaldi-stable.desktop" [
        "text/html"
        "application/pdf"
        "x-scheme-handler/about"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/unknown"
        "image/jpeg"
        "image/png"
        "image/svg"
        "image/gif"
        "image/webp"
        "image/mp4"
        "image/mpeg"
        "image/webm"
      ];

      wayland.windowManager.hyprland.settings.windowrule = lib.mkIf config.wayland.windowManager.hyprland.enable [
        "tile, ^(Vivaldi-stable)$"
      ];

      programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
        "vivaldi" = "󰖟";
      };
    };
}
