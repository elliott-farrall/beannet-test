{ ... }:

{
  flake.modules.homeManager."programs/foot" = { lib, config, ... }: {
    programs.foot.enable = true;

    home.sessionVariables.TERMINAL = lib.getExe config.programs.foot.package;

    desktop.wmIcons."foot" = "󰆍";
    desktop.wmIcons."footclient" = "󰆍";
  };
}
