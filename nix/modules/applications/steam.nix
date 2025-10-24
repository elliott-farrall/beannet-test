{ ... }:

{
  flake.modules.nixos.default = { lib, config, ... }: {
    options = {
      applications.steam.enable = lib.mkEnableOption "the Steam application";
    };

    config = lib.mkIf config.applications.steam.enable {
      programs.steam.enable = true;
    };
  };
}
