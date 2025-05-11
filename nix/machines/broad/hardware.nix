{ inputs, config, ... }:

{
  flake.clan.machines."broad" = { ... }: {
    imports = [
      inputs.nixos-hardware.nixosModules.common-pc
      inputs.nixos-hardware.nixosModules.common-pc-ssd
      inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
      inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
      config.flake.modules.nixos."disks/zfs"
    ];

    disko.devices.disk."main".device = "/dev/disk/by-id/nvme-Patriot_M.2_P300_128GB_P300EDBB23033100980";

    hardware.nvidia.open = false;

    clan.core.networking.targetHost = "";

    networking.usePredictableInterfaceNames = false;

    systemd.network.links = {
      "10-ethExt" = {
        linkConfig.Name = "ethExt";
        matchConfig.PermanentMACAddress = "ac:15:a2:85:1b:28";
      };
    };
  };
}
