{ inputs, config, ... }:

with inputs.nixos-hardware.nixosModules;
with config.flake.modules.nixos;
{
  flake.clan.machines."lima" = { ... }: {
    imports = [
      framework-12th-gen-intel
      disks-zfs
    ];

    disko.devices.disk."main".device = "/dev/disk/by-id/nvme-Samsung_SSD_970_PRO_512GB_S463NF0K800096J";

    devices.audio.enable = true;
    devices.bluetooth.enable = true;
    devices.printing.enable = true;

    devices.display = {
      enable = true;
      output = "eDP-1";

      width = 2256;
      height = 1504;

      refresh = 60;

      scale = 1.333333;
    };
  };
}
