{ ... }:

{
  flake.modules.homeManager."terminal/foot" = { lib, config, ... }: {
    programs.foot.enable = true;

    home.sessionVariables.TERMINAL = lib.getExe config.programs.foot.package;

    programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
      "foot" = "󰆍";
      "footclient" = "󰆍";
    };
  };
}
