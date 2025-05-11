{ ... }:

{
  flake.modules.nixos."greeter/tuigreet" = { lib, pkgs, config, ... }:
    let
      inherit (config.services.displayManager.sessionData) desktops;

      inherit (config.catppuccin) accentBase16;
    in
    {
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
}
