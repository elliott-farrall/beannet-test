{ lib, config, ... }:

let
  machines = config.flake.clan.nixosConfigurations;

  beanBlocks = lib.mapAttrs
    (name: _machine: {
      hostname = "${name}.bean";
      user = "root";
      identityFile = "~/.ssh/credentials/${name}";
      proxyJump = "beanbag";
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
      matchBlocks = beanBlocks // {
        beanbag = {
          hostname = "ssh.bean.directory";
          user = "root";
          identityFile = "~/.ssh/credentials/runner";
        };
      };
    };
  };
}
