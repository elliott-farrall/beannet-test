{ ... }:

{
  flake.modules.nixos.default = { lib, config, ... }: {
    options = {
      devices.bluetooth.enable = lib.mkEnableOption "bluetooth";
    };

    config = lib.mkIf config.devices.bluetooth.enable {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    };
  };
}
