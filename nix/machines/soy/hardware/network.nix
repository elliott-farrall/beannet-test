{ ... }:

{
  flake.clan.machines."soy" = { ... }: {
    systemd.network.links = {
      "10-eth" = {
        linkConfig.Name = "eth";
        matchConfig.PermanentMACAddress = "74:56:3c:35:1d:9d";
      };
    };
    networking.usePredictableInterfaceNames = false;
  };
}
