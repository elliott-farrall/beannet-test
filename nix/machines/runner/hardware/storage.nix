{ config, ... }:

{
  flake.clan.machines."runner" = { ... }: {
    imports = with config.flake.modules; [ nixos."disks/zfs" ];
    disko.devices.disk."main".device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_101411942";
  };
}
