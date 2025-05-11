{ config, ... }:

{
  flake.modules.nixos."default" = { lib, ... }: {
    services.openssh.settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = lib.mkForce true;
    };
  };

  flake.modules.homeManager."default" = { lib, ... }:
    let
      mkMatchBlock = name: machine: {
        "${name}.local" = {
          hostname = "${name}.local";
          user = "root";
          identityFile = machine.config.sops.secrets."ssh_root".path; # TODO : Migrate to vars
          match = "host ${name} exec 'nc -z ${name}.local %p'";
        };
        "${name}.vpn" = {
          hostname = machine.config.clan.core.vars.generators.zerotier.files.zerotier-ip.value;
          user = "root";
          identityFile = machine.config.sops.secrets."ssh_root".path; # TODO : Migrate to vars
          match = "host ${name}";
        };
      };
      nodes = lib.filterAttrs (name: _: builtins.elem name config.flake.clan.inventory.tags.nodes) config.flake.clan.nixosConfigurations;
    in
    {
      services.ssh-agent.enable = true;

      programs.ssh = {
        enable = true;
        matchBlocks = lib.mkMerge (lib.mapAttrsToList mkMatchBlock nodes);
      };
    };
}
