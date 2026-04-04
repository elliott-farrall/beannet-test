{ lib, config, ... }:

let
  machines = config.flake.clan.nixosConfigurations;

  getKey = machine: "${config.flake.clan.directory}/vars/per-machine/${machine}/openssh/ssh.id_ed25519/secret";
in
{
  flake.modules.nixos.default = { lib, ... }: {
    services.openssh = {
      settings = {
        PermitRootLogin = "yes";
        PasswordAuthentication = lib.mkForce true;
      };
    };

    programs.ssh.extraConfig = ''
      ${with machines.runner.config.clan.core; ''
        Host beanbag
          Hostname ssh.${settings.domain}
          User root
          IdentityFile ${vars.generators.openssh.files."ssh.id_ed25519".path}
      ''}

      ${lib.concatLines (lib.mapAttrsToList (name: machine: with machine.config.clan.core; ''
        Host ${name}.${settings.domain}
          User root
          IdentityFile ${vars.generators.openssh.files."ssh.id_ed25519".path}
          ProxyJump beanbag
      '') machines)}
      ${lib.concatLines (lib.mapAttrsToList (_name: machine: with machine.config.clan.core; ''
        Host ${vars.generators.zerotier.files.zerotier-ip.value}
          User root
          IdentityFile ${vars.generators.openssh.files."ssh.id_ed25519".path}
          ProxyJump beanbag
      '') machines)}
      ${lib.concatLines (lib.mapAttrsToList (_name: machine: with machine.config.clan.core; ''
        Host ${vars.generators.yggdrasil.files.address.value}
          User root
          IdentityFile ${vars.generators.openssh.files."ssh.id_ed25519".path}
          ProxyJump beanbag
      '') machines)}
    '';

    services.fail2ban.enable = true;
  };

  flake.modules.homeManager.default = args: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks =
        let
          inherit (args.config.sops) secrets;
          runner = machines.runner.config.clan.core;
        in
        { "*".userKnownHostsFile = "~/.ssh/hosts/known_hosts"; }
        // {
          beanbag = {
            hostname = "ssh.${runner.settings.domain}";
            user = "root";
            identityFile = "~/${secrets."runner-root-private-key".path}";
          };
        }
        // lib.mapAttrs'
          (name: machine:
            lib.nameValuePair "${name}.${machine.config.clan.core.settings.domain}" {
              user = "root";
              identityFile = "~/${secrets."${name}-root-private-key".path}";
              proxyJump = "beanbag";
            }
          )
          machines
        // lib.mapAttrs'
          (name: machine:
            lib.nameValuePair machine.config.clan.core.vars.generators.zerotier.files.zerotier-ip.value {
              user = "root";
              identityFile = "~/${secrets."${name}-root-private-key".path}";
              proxyJump = "beanbag";
            }
          )
          machines
        // lib.mapAttrs'
          (name: machine:
            lib.nameValuePair machine.config.clan.core.vars.generators.yggdrasil.files.address.value {
              user = "root";
              identityFile = "~/${secrets."${name}-root-private-key".path}";
              proxyJump = "beanbag";
            }
          )
          machines;
    };

    sops.secrets = lib.mapAttrs'
      (name: _machine: {
        name = "${name}-root-private-key";
        value = {
          sopsFile = getKey name;
          path = ".ssh/credentials/${name}-root";
          format = "binary";
        };
      })
      machines;

    home.persistence.state.directories = [ ".ssh/hosts" ];
  };
}
