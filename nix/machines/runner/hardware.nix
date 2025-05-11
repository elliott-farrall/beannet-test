{ config, ... }:

{
  flake.clan.machines."runner" = { lib, ... }: {
    imports = [
      config.flake.modules.nixos."disks/zfs"
    ];

    disko.devices.disk."main".device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_62047276";

    clan.core.networking.targetHost = "88.198.151.191";

    boot.loader = {
      grub.efiSupport = lib.mkForce false;
      efi.canTouchEfiVariables = lib.mkForce false;
    };
  };
}
