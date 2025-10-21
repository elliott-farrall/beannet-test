{ ... }:

{
  flake.modules.homeManager."programs/alacritty" = { lib, config, ... }: {
    programs.alacritty.enable = true;

    home.sessionVariables.TERMINAL = lib.getExe config.programs.alacritty.package;

    desktop.wmIcons."alacritty" = "󰆍";
  };
}
