{ ... }:

{
  flake.modules.homeManager."default" = { lib, config, ... }: {
    options = {
      desktop.components.swayosd.enable = lib.mkEnableOption "the swayosd desktop component";
    };

    config = lib.mkIf config.desktop.components.swayosd.enable {
      services.swayosd.enable = true;
    };
  };
}
