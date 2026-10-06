{ ... }:

{
  flake.clan.machines."runner" = {
    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "server";
      extraSetFlags = [ "--advertise-exit-node" ];
      extraDaemonFlags = [ "--no-logs-no-support" ];
    };
  };
}
