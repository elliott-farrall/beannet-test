{ ... }:

{
  clan.machines."runner" = { ... }: {
    networking.firewall.allowedTCPPorts = [ 80 ];

    services.nginx.enable = true;

    clan.core.networking.zerotier.controller = {
      enable = true;
      public = true;
    };
  };
}
