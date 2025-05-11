{ inputs, config, ... }:

{
  flake.clan.machines."soy" = { ... }: {
    imports = [
      inputs.nixos-hardware.nixosModules.common-pc
      inputs.nixos-hardware.nixosModules.common-pc-ssd
      inputs.nixos-hardware.nixosModules.common-cpu-intel-cpu-only
      inputs.nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
      config.flake.modules.nixos."disks/zfs"
    ];

    disko.devices.disk."main".device = "/dev/disk/by-id/ata-Samsung_SSD_860_PRO_4TB_S42SNX0R900252J";

    hardware.nvidia.open = false;

    clan.core.networking.targetHost = "";

    networking.usePredictableInterfaceNames = false;

    systemd.network.links = {
      "10-eth" = {
        linkConfig.Name = "eth";
        matchConfig.PermanentMACAddress = "74:56:3c:35:1d:9d";
      };
    };
  };
}
