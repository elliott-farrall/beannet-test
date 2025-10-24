{ ... }:

{
  flake.modules.nixos.default = { lib, pkgs, config, ... }:
    let
      inherit (config.services.displayManager.sessionData) desktops;

      inherit (config.catppuccin) accentBase16;
    in
    {
      options = {
        greeter.tuigreet.enable = lib.mkEnableOption "the Tuigreet greeter";
      };

      config = lib.mkIf config.greeter.tuigreet.enable {
        services.greetd = {
          enable = true;

          #FIXME - Incorrect resolutions on multi-monitor setups
          settings.default_session.command = ''${lib.getExe pkgs.tuigreet} \
            --remember \
            --remember-session \
            --user-menu \
            --session-wrapper '${pkgs.execline}/bin/exec > /dev/null' \
            --sessions ${desktops}/share/wayland-sessions \
            --xsessions ${desktops}/share/xsessions \
            --theme 'border=${accentBase16};prompt=${accentBase16};action=${accentBase16}'
          '';
        };
      };
    };
}
