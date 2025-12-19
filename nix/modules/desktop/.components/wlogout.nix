{ ... }:

{
  flake.modules.homeManager.default = { lib, config, ... }: {
    options = {
      desktop.components.wlogout.enable = lib.mkEnableOption "the wlogout desktop component";
    };

    config = lib.mkIf config.desktop.components.wlogout.enable {
      programs.wlogout.enable = true;
    };
  };
}
