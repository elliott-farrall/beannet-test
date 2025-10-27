{ ... }:

{
  flake.modules.nixos.disks-flash = { ... }: {
    disko.devices = {
      disk."main" = {
        content = {
          type = "gpt";

          partitions ."boot" = {
            type = "EF02";
            size = "1M";
            priority = 1;
          };
          partitions."ESP" = {
            type = "EF00";
            size = "512M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          partitions."root" = {
            name = "root";
            end = "-0";
            content = {
              type = "filesystem";
              format = "f2fs";
              mountpoint = "/";
              extraArgs = [ "-O" "extra_attr,inode_checksum,sb_checksum,compression" ];
              mountOptions = [ "compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime,nodiscard" ];
            };
          };
        };
      };
    };
  };
}
