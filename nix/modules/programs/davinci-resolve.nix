{ ... }:

{
  flake.modules.homeManager."default" = { lib, pkgs, config, ... }: {
    options = {
      programs.davinci-resolve.enable = lib.mkEnableOption "DaVinci Resolve";
    };

    config = lib.mkIf config.programs.davinci-resolve.enable {
      home.packages = with pkgs; [
        davinci-resolve
      ];
    };
  };
}
