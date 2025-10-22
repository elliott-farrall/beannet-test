{ ... }:

{
  flake.clan.machines."sprout" = { ... }: {
    networking = {
      firewall.enable = true;

      nat = {
        enable = true;
        enableIPv6 = true;

        internalInterfaces = [ "br" ];
        externalInterface = "wan";
      };
    };
  };
}
