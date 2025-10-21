{ inputs, config, ... }:

with inputs.nixos-hardware.nixosModules;
{
  flake.clan.machines."broad" = { ... }: {
    imports = with config.flake.modules; [
      common-pc
      common-pc-ssd
      common-cpu-intel-cpu-only
      common-gpu-nvidia-nonprime
      nixos."disks/zfs"
    ];

    disko.devices.disk."main".device = "/dev/disk/by-id/nvme-Patriot_M.2_P300_128GB_P300EDBB23033100980";

    systemd.network.links = {
      "10-ethExt" = {
        linkConfig.Name = "ethExt";
        matchConfig.PermanentMACAddress = "ac:15:a2:85:1b:28";
      };
    };
    networking.usePredictableInterfaceNames = false;

    hardware.nvidia.open = false;
  };
}
