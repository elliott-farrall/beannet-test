{ lib, config, ... }:

let
  machines = config.flake.clan.nixosConfigurations;

  root-private-keys = lib.mapAttrs'
    (name: _machine: {
      name = "${name}-root-private-key";
      value = {
        sopsFile = "${config.clan.directory}/vars/per-machine/${name}/root-ssh-key/private-key/secret";
        path = ".ssh/credentials/${name}-root";
        format = "binary";
      };
    })
    machines;

  beanBlocks = lib.mapAttrs'
    (name: _machine: {
      name = "${name}.bean";
      value = {
        hostname = "${name}.bean";
        user = "root";
        identityFile = "~/.ssh/credentials/${name}-root";
        proxyJump = "beanbag";
      };
    })
    machines;

  vpnBlocks = lib.mapAttrs'
    (name: machine: {
      name = machine.config.clan.core.vars.generators.zerotier.files.zerotier-ip.value;
      value = {
        user = "root";
        identityFile = "~/.ssh/credentials/${name}-root";
      };
    })
    machines;

in
{
  flake.modules.nixos.default = { lib, ... }: {
    services.openssh.settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = lib.mkForce true;
    };
  };

  flake.modules.homeManager.default = { ... }: {
    services.ssh-agent.enable = true;

    programs.ssh = {
      enable = true;
      matchBlocks = beanBlocks // vpnBlocks // {
        "beanbag" = {
          hostname = "ssh.bean.directory";
          user = "root";
          identityFile = "~/.ssh/credentials/runner-root";
        };
      };
    };

    sops.secrets = root-private-keys;

    home.persistence.state.files = [ ".ssh/known_hosts" ];
  };
}
