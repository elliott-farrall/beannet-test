{ ... }:

{
  flake.modules.homeManager."default" = { lib, config, ... }: {
    options = {
      applications.foot.enable = lib.mkEnableOption "the Foot application";
    };

    config = lib.mkIf config.applications.foot.enable {
      programs.foot.enable = true;

      home.sessionVariables.TERMINAL = lib.getExe config.programs.foot.package;

      desktop.wmIcons."foot" = "󰆍";
      desktop.wmIcons."footclient" = "󰆍";
    };
  };
}
