{ config, ... }:

{
  # TODO - sshd clanModule gets auto-imported by admin clanService
  # flake.clan.inventory.instances."ssh" = {
  #   module = {
  #     name = "sshd";
  #     input = "clan-core";
  #   };
  #   roles.server.tags."nodes" = {};
  # };

  flake.modules.nixos."default" = { lib, ... }: {
    services.openssh.settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = lib.mkForce true;
    };
  };

  flake.modules.homeManager."default" = { lib, nixosConfig, ... }: {
    services.ssh-agent.enable = true;

    programs.ssh = {
      enable = true;

      matchBlocks = (builtins.mapAttrs
        (_: machine: {
          hostname = machine.config.clan.core.vars.generators.zerotier.files.zerotier-ip.value;
          user = "root";
          identityFile = machine.config.sops.secrets."ssh_root".path;
        })
        (lib.filterAttrs (name: _: builtins.elem name config.flake.clan.inventory.tags.nodes) config.flake.clan.nixosConfigurations)) // {

        /* ----------------------------- PythonAnywhere ----------------------------- */

        "ssh.eu.pythonanywhere.com" = {
          user = "ElliottSF";
          identityFile = nixosConfig.sops.secrets."ssh_python-anywhere".path;
        };

        /* ----------------------------------- UoS ---------------------------------- */

        AccessEPS = {
          hostname = "access.eps.surrey.ac.uk";
          user = "es00569";
          identityFile = nixosConfig.sops.secrets."ssh_uos".path;
          forwardX11 = true;
          forwardX11Trusted = true;
        };
        MathsCompute01 = {
          hostname = "maths-compute01";
          user = "es00569";
          identityFile = nixosConfig.sops.secrets."ssh_uos".path;
          forwardX11 = true;
          forwardX11Trusted = true;
          proxyJump = "AccessEPS";
        };
      };
    };
  };
}
