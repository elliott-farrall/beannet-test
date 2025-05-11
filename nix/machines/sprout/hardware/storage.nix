{ config, ... }:

{
  flake.clan.machines."sprout" = { ... }: {
    imports = with config.flake.modules; [ nixos."disks/zfs" ];
    disko.devices.disk."main".device = "/dev/disk/by-id/ata-NGFF_2280_512GB_SSD_20241017101421";
  };
}
