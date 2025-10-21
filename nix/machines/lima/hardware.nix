{ inputs, config, ... }:

with inputs.nixos-hardware.nixosModules;
{
  flake.clan.machines."lima" = { ... }: {
    imports = with config.flake.modules; [
      framework-12th-gen-intel
      nixos."disks/zfs"
      nixos."devices/audio"
      nixos."devices/bluetooth"
      nixos."devices/printing"
    ];

    disko.devices.disk."main".device = "/dev/disk/by-id/nvme-Samsung_SSD_970_PRO_512GB_S463NF0K800096J";

    display = {
      enable = true;
      output = "eDP-1";

      width = 2256;
      height = 1504;

      refresh = 60;

      scale = 1.333333;
    };
  };
}
