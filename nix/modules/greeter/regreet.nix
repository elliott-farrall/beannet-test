{ ... }:

{
  flake.modules.nixos."greeter/regreet" = { config, ... }:
    let
      inherit (config.services.displayManager.sessionData) desktops;
    in
    {
      programs.regreet = {
        enable = true;
        cageArgs = [ "-s" "-m" "last" ];

        settings = {
          env.SESSION_DIRS = "${desktops}/share/xsessions:${desktops}/share/wayland-sessions";

          background = {
            path = config.lib.stylix.pixel "base02";
            fit = "Fill";
          };
        };
      };

      stylix.targets.regreet.useWallpaper = false;
    };
}
