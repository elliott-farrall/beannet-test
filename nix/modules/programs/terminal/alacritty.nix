{ ... }:

{
  flake.modules.homeManager."programs/alacritty" = { lib, config, ... }: {
    programs.alacritty.enable = true;

    home.sessionVariables.TERMINAL = lib.getExe config.programs.alacritty.package;

    programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
      "alacritty" = "󰆍";
    };
  };
}
