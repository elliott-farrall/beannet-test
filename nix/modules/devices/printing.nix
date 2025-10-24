{ ... }:

{
  flake.modules.nixos.default = { lib, config, ... }: {
    options = {
      devices.printing.enable = lib.mkEnableOption "printing support";
    };

    config = lib.mkIf config.devices.printing.enable {
      services.printing.enable = true;
      services.colord.enable = true;
    };
  };
}
