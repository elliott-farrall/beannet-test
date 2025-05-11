{ inputs, ... }:

{
  imports = with inputs.self.modules; [ nixos."disks/zfs" ];
  disko.devices.disk."main".device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_62047276";
}
