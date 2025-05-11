{ ... }:

{
  flake.modules.nixos."machines/sprout" = { lib, ... }: {
    boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = lib.mkForce true; #FIXME: NAT should set these
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = lib.mkForce true;

    networking = {
      firewall.enable = true;

      nat = {
        enable = true;
        enableIPv6 = true;

        internalInterfaces = [ "lan" ];
        externalInterface = "wan";
      };
    };
  };
}
