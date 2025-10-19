{ lib, config, ... }:

let
  machines = config.flake.clan.nixosConfigurations;

  beanBlocks = lib.mapAttrs'
    (name: _machine: {
      name = "${name}.bean";
      value = {
        hostname = "${name}.bean";
        user = "root";
        identityFile = "~/.ssh/credentials/root";
        proxyJump = "beanbag";
      };
    })
    machines;

  vpnBlocks = lib.mapAttrs'
    (_name: machine: {
      name = machine.config.clan.core.vars.generators.zerotier.files.zerotier-ip.value;
      value = {
        user = "root";
        identityFile = "~/.ssh/credentials/root";
      };
    })
    machines;

in
{
  flake.modules.nixos."default" = { lib, ... }: {
    services.openssh.settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = lib.mkForce true;
    };
  };

  flake.modules.homeManager."default" = { ... }: {
    services.ssh-agent.enable = true;

    programs.ssh = {
      enable = true;
      matchBlocks = beanBlocks // vpnBlocks // {
        "beanbag" = {
          hostname = "ssh.bean.directory";
          user = "root";
          identityFile = "~/.ssh/credentials/root";
        };
      };
    };

    sops.secrets."root-private-key" = {
      sopsFile = "${config.clan.directory}/vars/shared/root/private-key/secret";
      path = ".ssh/credentials/root";
      format = "binary";
    };
  };
}
