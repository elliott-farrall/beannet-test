{ ... }:

{
  flake.clan.machines."sprout" = { config, ... }: {
    clan.core.networking.targetHost = "${config.system.name}.local";

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
