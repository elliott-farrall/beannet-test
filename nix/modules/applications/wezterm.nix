{ ... }:

{
  flake.modules.homeManager.default = { lib, config, ... }: {
    options = {
      applications.wezterm.enable = lib.mkEnableOption "the WezTerm application";
    };

    config = lib.mkIf config.applications.wezterm.enable {
      programs.wezterm.enable = true;

      home.sessionVariables.TERMINAL = lib.getExe config.programs.wezterm.package;

      desktop.wmIcons."wezterm" = "󰆍";
    };
  };
}
