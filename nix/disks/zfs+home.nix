{ config, ... }:

{
  flake.modules.nixos."disks/zfs+home" = { ... }: {
    imports = with config.flake.modules; [ nixos."disks/zfs" ];

    disko.devices.zpool."nixos".datasets."home" = {
      type = "zfs_fs";
      mountpoint = "/home";
    };
  };
}
