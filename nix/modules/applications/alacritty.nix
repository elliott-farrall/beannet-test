{ ... }:

{
  flake.modules.homeManager.default = { lib, config, ... }: {
    options = {
      applications.alacritty.enable = lib.mkEnableOption "the Alacritty application";
    };

    config = lib.mkIf config.applications.alacritty.enable {
      programs.alacritty.enable = true;

      home.sessionVariables.TERMINAL = lib.getExe config.programs.alacritty.package;

      desktop.wmIcons."alacritty" = "󰆍";
    };
  };
}
