{ ... }:

{
  flake.modules.homeManager."default" = { lib, config, ... }: {
    options = {
      applications.kitty.enable = lib.mkEnableOption "the Kitty application";
    };

    config = lib.mkIf config.applications.kitty.enable {
      programs.kitty = {
        enable = true;
        settings.confirm_os_window_close = 0;
      };

      home.sessionVariables.TERMINAL = lib.getExe config.programs.kitty.package;

      desktop.wmIcons."kitty" = "󰆍";

      stylix.targets.kitty.enable = false;
    };
  };
}
