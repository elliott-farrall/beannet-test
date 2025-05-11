{ self, ... }:

{
  imports = with self.modules; [ nixos."disks/zfs+home" ];
  disko.devices.disk."main".device = "/dev/disk/by-id/ata-Samsung_SSD_860_PRO_4TB_S42SNX0R900252J";
}
