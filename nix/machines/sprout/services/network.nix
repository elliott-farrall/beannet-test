{ ... }:

{
  flake.clan.machines."sprout" = { lib, ... }: {
    networking = {
      networkmanager.enable = lib.mkForce false;
      useDHCP = false;

      bridges."br".interfaces = [ "lan" "wlan" ];

      interfaces."ont" = { };
      interfaces."lan" = { };
      interfaces."wlan" = { };
      interfaces."br" = {
        # FIXME - Still having issues with br getting IP addresses
        ipv4.addresses = [
          {
            address = "10.0.0.1";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "fd4e:2059:bccb:8400::1";
            prefixLength = 64;
          }
        ];
      };
    };
  };
}
