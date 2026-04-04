{ ... }:

{
  flake.clan.machines."soy" = { ... }: {
    wsl.enable = true;
    nixpkgs.hostPlatform.system = "x86_64-linux";

    networking = {
      defaultGateway = {
        address = "172.23.16.1";
        interface = "eth0";
      };

      interfaces."eth0" = {
        useDHCP = false;
        ipv4.addresses = [{ address = "172.23.16.2"; prefixLength = 20; }];
        mtu = 1400;
      };
    };
  };
}
