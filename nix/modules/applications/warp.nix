{ ... }:

{
  flake.modules.homeManager.default = { lib, pkgs, config, ... }: {
    options = {
      applications.warp.enable = lib.mkEnableOption "the Warp application";
    };

    config = lib.mkIf config.applications.warp.enable {
      home.packages = with pkgs; [ warp-terminal ];

      home.sessionVariables.TERMINAL = lib.getExe pkgs.warp-terminal;

      desktop.wmIcons."warp" = "󰆍";
    };
  };
}
