{ inputs, config, ... }:

with inputs.nixos-hardware.nixosModules;
{
  flake.clan.machines."runner" = { lib, ... }: {
    imports = with config.flake.modules; [
      nixos."disks/zfs"
    ];

    disko.devices.disk."main".device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_101411942";

    boot.loader = {
      grub.efiSupport = lib.mkForce false;
      efi.canTouchEfiVariables = lib.mkForce false;
    };
  };
}
