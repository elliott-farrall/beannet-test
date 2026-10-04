{ inputs, ... }:

{
  flake.modules.nixos.disks-zfs = { pkgs, config, ... }: {
    imports = with inputs; [ chaotic.nixosModules.zfs-impermanence-on-shutdown ];

    networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.system.name);

    # TODO: Remove after all machines have rebooted once with the new hostId.
    # Force-import the root pool once after the hostId change from MD5 to SHA-256.
    # This lets already-deployed machines boot with the new /etc/hostid without manual rescue.
    boot.zfs.forceImportRoot = true;

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
        rootFsOptions = {
          mountpoint = "none";
          acltype = "posixacl";
          xattr = "sa";
        }; # https://askubuntu.com/questions/970886/journalctl-says-failed-to-search-journal-acl-operation-not-supported

        datasets."root" = {
          type = "zfs_fs";
          mountpoint = "/";
          postCreateHook = "zfs snapshot nixos/root@blank";
        };
        datasets."nix" = {
          type = "zfs_fs";
          mountpoint = "/nix";
        };
        datasets."data" = {
          type = "zfs_fs";
          mountpoint = "/pst/data";
        };
        datasets."state" = {
          type = "zfs_fs";
          mountpoint = "/pst/state";
        };
        datasets."log" = {
          type = "zfs_fs";
          mountpoint = "/pst/log";
        };
        datasets."key" = {
          type = "zfs_fs";
          mountpoint = "/var/lib/sops-nix";
        };
      };
    };

    fileSystems."/var/lib/sops-nix".neededForBoot = true;
    fileSystems."/pst/data".neededForBoot = true;
    fileSystems."/pst/state".neededForBoot = true;
  };
}
