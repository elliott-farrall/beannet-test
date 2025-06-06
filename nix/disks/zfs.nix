{ inputs, ... }:

{
  flake.modules.nixos."disks/zfs" = { pkgs, config, ... }: {
    imports = with inputs; [ chaotic.nixosModules.zfs-impermanence-on-shutdown ];

    networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" config.system.name);

    environment.systemPackages = with pkgs; [ zfs ];

    chaotic.zfs-impermanence-on-shutdown = {
      enable = true;
      volume = "nixos/root";
      snapshot = "blank";
    };

    disko.devices = {
      disk."main" = {
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
  };
}
