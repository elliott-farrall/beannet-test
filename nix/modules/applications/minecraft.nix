{ ... }:

{
  flake.modules.homeManager.default = { lib, pkgs, config, ... }: {
    options = {
      applications.minecraft.enable = pkgs.lib.mkEnableOption "the Minecraft application";
    };

    config = lib.mkIf config.applications.minecraft.enable {
      home.packages = with pkgs; [ prismlauncher ];
    };
  };
}
