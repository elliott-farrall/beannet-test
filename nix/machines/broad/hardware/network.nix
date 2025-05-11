{ ... }:

{
  flake.clan.machines."broad" = { ... }: {
    systemd.network.links = {
      "10-ethExt" = {
        linkConfig.Name = "ethExt";
        matchConfig.PermanentMACAddress = "ac:15:a2:85:1b:28";
      };
    };
    networking.usePredictableInterfaceNames = false;
  };
}
