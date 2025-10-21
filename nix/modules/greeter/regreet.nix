{ ... }:

{
  flake.modules.nixos."default" = { lib, config, ... }:
    let
      inherit (config.services.displayManager.sessionData) desktops;
    in
    {
      options = {
        greeter.regreet.enable = lib.mkEnableOption "the Regreet greeter";
      };

      config = lib.mkIf config.greeter.regreet.enable {
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
    };
}
