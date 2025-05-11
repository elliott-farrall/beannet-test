{ config, ... }:

{
  flake.modules.nixos."machines/runner" = { lib, ... }:
    let
      machines = config.flake.clan.nixosConfigurations;
    in
    {
      services.dnsmasq = {
        enable = true;

        settings = {
          server = [ "1.1.1.1" "1.0.0.1" ];
          address = lib.mapAttrsToList (name: machine: "/${name}.bean/${machine.config.clan.core.vars.generators.zerotier.files.zerotier-ip.value}") machines;
        };
      };

      networking.firewall = {
        allowedUDPPorts = [ 53 ];
        allowedTCPPorts = [ 53 ];
      };

      services.resolved.enable = false;
    };
}
