{ ... }:

{
  flake.clan.machines."sprout" = { ... }: {
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
    networking.usePredictableInterfaceNames = false;
  };
}
