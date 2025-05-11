{ ... }:

{
  clan.machines."sprout" = { ... }: {
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
    };
  };
}
