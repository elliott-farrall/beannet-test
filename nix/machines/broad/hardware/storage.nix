{ config, ... }:

{
  flake.clan.machines."broad" = { ... }: {
    imports = with config.flake.modules; [ nixos."disks/zfs" ];
    disko.devices.disk."main".device = "/dev/disk/by-id/nvme-Patriot_M.2_P300_128GB_P300EDBB23033100980";
  };
}
