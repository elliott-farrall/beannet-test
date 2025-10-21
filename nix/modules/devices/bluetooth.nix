{ ... }:

{
  flake.modules.nixos."devices/bluetooth" = { ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
