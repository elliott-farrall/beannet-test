{ ... }:

{
  flake.modules.nixos.default = { lib, pkgs, config, ... }:
    let
      inherit (config.services.displayManager.sessionData) desktops;

      inherit (config.catppuccin) accent;
      accent' = lib.accentToBase16 accent;
    in
    {
      options = {
        greeter.tuigreet.enable = lib.mkEnableOption "the Tuigreet greeter";
      };

      config = lib.mkIf config.greeter.tuigreet.enable {
        services.greetd = {
          enable = true;

          # FIXME - Incorrect resolutions on multi-monitor setups
          settings.default_session.command = ''${lib.getExe pkgs.tuigreet} \
            --remember \
            --remember-session \
            --user-menu \
            --session-wrapper '${pkgs.execline}/bin/exec > /dev/null' \
            --sessions ${desktops}/share/wayland-sessions \
            --xsessions ${desktops}/share/xsessions \
            --theme 'border=${accent'};prompt=${accent'};action=${accent'}'
          '';
        };
      };
    };
}
