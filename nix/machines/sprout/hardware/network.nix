{ ... }:

{
  flake.clan.machines."sprout" = { ... }: {
    systemd.network.links = {
      "10-ont" = {
        linkConfig.Name = "ont";
        matchConfig.PermanentMACAddress = "e8:ff:1e:dd:89:77";
      };
      "10-lan" = {
        linkConfig.Name = "lan";
        matchConfig.PermanentMACAddress = "e8:ff:1e:dd:89:76";
      };
      "10-wlan" = {
        linkConfig.Name = "wlan";
        matchConfig.PermanentMACAddress = "ce:bf:1a:2b:ee:2f";
      };
    };
    networking.usePredictableInterfaceNames = false;
  };
}
