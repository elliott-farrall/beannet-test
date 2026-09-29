{ ... }:

{
  flake.modules.nixos.default = { lib, pkgs, config, ... }:
    let
      inherit (config.services.displayManager.sessionData) desktops;

      inherit (config.catppuccin) accent;
      accent' = config.lib.stylix.colors.withHashtag.${lib.accentToBase16 accent};

      session-wrapper = pkgs.writeShellScript "tuigreet-session-wrapper" "exec > /dev/null";
    in
    {
      options = {
        greeter.tuigreet.enable = lib.mkEnableOption "the Tuigreet greeter";
      };

      config = lib.mkIf config.greeter.tuigreet.enable {
        services.greetd = {
          enable = true;

          # FIXME - Incorrect resolutions on multi-monitor setups
          settings.default_session.command = lib.concatStringsSep " " [
            (lib.getExe pkgs.tuigreet)
            "--remember"
            "--remember-session"
            "--user-menu"
            "--session-wrapper '${session-wrapper}'"
            "--sessions ${desktops}/share/wayland-sessions"
            "--xsessions ${desktops}/share/xsessions"
            "--theme 'border=${accent'};prompt=${accent'};action=${accent'}'"
          ];
        };
      };
    };
}
