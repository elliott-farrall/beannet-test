{ ... }:

{
  flake.modules.homeManager."programs/wezterm" = { lib, config, ... }: {
    programs.wezterm.enable = true;

    home.sessionVariables.TERMINAL = lib.getExe config.programs.wezterm.package;

    programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
      "wezterm" = "󰆍";
    };
  };
}
