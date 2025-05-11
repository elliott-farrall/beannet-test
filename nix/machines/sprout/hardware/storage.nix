{ config, ... }:

{
  flake.clan.machines."sprout" = { ... }: {
    imports = with config.flake.modules; [
      nixos."disks/zfs"
    ];

    disko.devices.disk."main".device = "/dev/disk/by-id/nvme-INTEL_SSDPEDME400G4_CVMD43820041400AGN";
  };
}
