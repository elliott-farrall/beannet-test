{ ... }:

{
  disko.devices = {
    disk."main" = {
      name = "main-{{uuid}}";
      device = "{{mainDisk}}";

      content = {
        type = "gpt";

        partitions."boot" = {
          type = "EF02";
          size = "1M";
        };
        partitions."efi" = {
          type = "EF00";
          size = "512M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        partitions."nixos" = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "nixos";
          };
        };
      };
    };

    zpool."nixos" = {
      rootFsOptions.mountpoint = "none";

      datasets."root" = {
        type = "zfs_fs";
        mountpoint = "/";
        postCreateHook = "zfs snapshot nixos/root@blank";
      };
      datasets."nix" = {
        type = "zfs_fs";
        mountpoint = "/nix";
      };
      datasets."sops" = {
        type = "zfs_fs";
        mountpoint = "/var/lib/sops-nix";
      };
      datasets."persist" = {
        type = "zfs_fs";
        mountpoint = "/persist";
      };
    };
  };
}
