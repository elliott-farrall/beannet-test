{ config, ... }:

{
  flake.clan.machines."soy" = { ... }: {
    imports = with config.flake.modules; [ nixos."disks/zfs" ];
    disko.devices.disk."main".device = "/dev/disk/by-id/ata-Samsung_SSD_860_PRO_4TB_S42SNX0R900252J";
  };
}
