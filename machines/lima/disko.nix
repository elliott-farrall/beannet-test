{ self, ... }:

{
  imports = with self.modules; [ nixos."disks/zfs+home" ];
  disko.devices.disk."main".device = "/dev/disk/by-id/nvme-Samsung_SSD_970_PRO_512GB_S463NF0K800096J";
}
