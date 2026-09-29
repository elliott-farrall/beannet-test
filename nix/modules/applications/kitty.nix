{ ... }:

{
  flake.modules.homeManager.default = { lib, config, ... }: {
    config = {
      programs.kitty = {
        enable = true;
        settings.confirm_os_window_close = 0;
      };

      home.sessionVariables.TERMINAL = lib.getExe config.programs.kitty.package;

      desktop.wmIcons."kitty" = "󰆍";
    };
  };
}
