{ inputs, ... }:

{
  flake.clan.machines."soy" = { ... }: {
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
      "10-eth" = {
        linkConfig.Name = "eth";
        matchConfig.PermanentMACAddress = "74:56:3c:35:1d:9d";
      };
    };
  };
}
