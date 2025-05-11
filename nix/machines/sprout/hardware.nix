{ inputs, ... }:

{
  flake.clan.machines."sprout" = { ... }: {
    imports = with inputs.nixos-hardware.nixosModules; [
      common-pc
      common-pc-ssd
      common-cpu-intel-cpu-only
    ];

    clan.core.networking.targetHost = "192.168.1.1";

    networking.usePredictableInterfaceNames = false;

    systemd.network.links = {
      "10-ont" = {
        linkConfig.Name = "ont";
        matchConfig.PermanentMACAddress = "d4:5d:64:bb:79:75";
      };
      "10-lan" = {
        linkConfig.Name = "lan";
        matchConfig.PermanentMACAddress = "d4:5d:64:bb:79:74";
      };
      "10-wlan" = {
        linkConfig.Name = "wlan";
        matchConfig.PermanentMACAddress = "ec:75:0c:42:fa:b5";
      };
    };
  };
}
