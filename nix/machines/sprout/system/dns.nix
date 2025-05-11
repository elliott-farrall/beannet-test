{ ... }:

{
  flake.clan.machines."sprout" = { config, ... }: {
    services.dnsmasq = {
      enable = true;

      settings = {
        enable-ra = true;

        server = [
          "1.1.1.1" # Cloudflare
          "1.0.0.1" # Cloudflare
        ];

        local = "/beannet.local/";
        domain = "beannet.local";

        address = [
          "/${config.networking.hostName}.beannet.local/192.168.1.1"
        ];

        dhcp-range = [
          "192.168.1.101,192.168.1.254"
          "::f,::ff,constructor:lan,ra-names"
        ];
        dhcp-option = [ "option:dns-server,192.168.1.1" ];
      };
    };

    networking.firewall.interfaces."br" = {
      allowedUDPPorts = [ 53 67 ];
      allowedTCPPorts = [ 53 ];
    };

    services.resolved.enable = false;
  };
}
