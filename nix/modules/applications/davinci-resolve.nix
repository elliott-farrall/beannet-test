{ ... }:

{
  flake.modules.homeManager.default = { lib, pkgs, config, ... }: {
    options = {
      applications.davinci-resolve.enable = pkgs.lib.mkEnableOption "the DaVinci Resolve application";
    };

    config = lib.mkIf config.applications.davinci-resolve.enable {
      home.packages = with pkgs; [ davinci-resolve ];
    };
  };
}
