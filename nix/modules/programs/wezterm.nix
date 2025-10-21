{ ... }:

{
  flake.modules.homeManager."programs/wezterm" = { lib, config, ... }: {
    programs.wezterm.enable = true;

    home.sessionVariables.TERMINAL = lib.getExe config.programs.wezterm.package;

    desktop.wmIcons."wezterm" = "󰆍";
  };
}
