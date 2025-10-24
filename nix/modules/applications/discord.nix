{ ... }:

{
  flake.modules.homeManager.default = { lib, pkgs, config, ... }: {
    options = {
      applications.discord.enable = pkgs.lib.mkEnableOption "the Discord application";
    };

    config = lib.mkIf config.applications.discord.enable {
      home.packages = with pkgs; [
        discord
        vesktop
      ];

      desktop.wmIcons."discord" = "󰙯";
    };
  };
}
