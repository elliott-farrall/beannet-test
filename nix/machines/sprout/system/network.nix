{ ... }:

{
  clan.machines."sprout" = { ... }: {
    # boot.kernelParams = [ "ipv6.disable=1" ];

    networking = {
      useDHCP = false;

      interfaces."ont" = { };
      interfaces."lan" = {
        ipv4.addresses = [
          {
            address = "192.168.1.1";
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
