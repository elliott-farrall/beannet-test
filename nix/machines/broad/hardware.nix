{ inputs, ... }:

{
  flake.clan.machines."broad" = { ... }: {
    imports = with inputs.nixos-hardware.nixosModules; [
      common-pc
      common-pc-ssd
      common-cpu-intel-cpu-only
      common-gpu-nvidia-nonprime
      { hardware.nvidia.open = false; }
    ];

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
