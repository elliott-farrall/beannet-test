{ ... }:

let
  subnet = "10.0.0";
in
{
  flake.clan.machines."sprout" = { ... }: {
    services.dnsmasq = {
      enable = true;

      settings = {
        enable-ra = true;

        server = [
          "1.1.1.1"
          "1.0.0.1"
        ];

        dhcp-range = [
          "${subnet}.101,${subnet}.254"
          "::f,::ff,constructor:br"
        ];

        dhcp-option = [
          "option:router,${subnet}.1"
          "option:dns-server,${subnet}.1"
        ];
      };
    };

    services.avahi.allowInterfaces = [ "br" ];

    networking.firewall.interfaces."br" = {
      allowedUDPPorts = [ 53 67 ];
      allowedTCPPorts = [ 53 ];
    };

    services.resolved.enable = false;
  };
}
