{ lib, config, ... }:

let
  machines = config.flake.clan.nixosConfigurations;

  getKey = machine: "${config.clan.directory}/vars/per-machine/${machine}/root-ssh-key/private-key/secret";
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
          IdentityFile ${vars.generators.root-ssh-key.files.private-key.path}
      ''}

      ${lib.concatLines (lib.mapAttrsToList (name: machine: with machine.config.clan.core; ''
        Host ${name}.${settings.domain}
          User root
          IdentityFile ${vars.generators.root-ssh-key.files.private-key.path}
          ProxyJump beanbag
      '') machines)}
      ${lib.concatLines (lib.mapAttrsToList (_name: machine: with machine.config.clan.core; ''
        Host ${vars.generators.zerotier.files.zerotier-ip.value}
          User root
          IdentityFile ${vars.generators.root-ssh-key.files.private-key.path}
          ProxyJump beanbag
      '') machines)}
      ${lib.concatLines (lib.mapAttrsToList (_name: machine: with machine.config.clan.core; ''
        Host ${vars.generators.yggdrasil.files.address.value}
          User root
          IdentityFile ${vars.generators.root-ssh-key.files.private-key.path}
          ProxyJump beanbag
      '') machines)}
    '';

    services.fail2ban.enable = true;
  };

  flake.modules.homeManager.default = args: {
    programs.ssh = {
      enable = true;

      extraConfig = let inherit (args.config.sops) secrets; in ''
        ${with machines.runner.config.clan.core; ''
          Host beanbag
            Hostname ssh.${settings.domain}
            User root
            IdentityFile ~/${secrets."runner-root-private-key".path}
        ''}

        ${lib.concatLines (lib.mapAttrsToList (name: machine: with machine.config.clan.core; ''
          Host ${name}.${settings.domain}
            User root
            IdentityFile ~/${secrets."${name}-root-private-key".path}
            ProxyJump beanbag
        '') machines)}
        ${lib.concatLines (lib.mapAttrsToList (name: machine: with machine.config.clan.core; ''
          Host ${vars.generators.zerotier.files.zerotier-ip.value}
            User root
            IdentityFile ~/${secrets."${name}-root-private-key".path}
            ProxyJump beanbag
        '') machines)}
        ${lib.concatLines (lib.mapAttrsToList (name: machine: with machine.config.clan.core; ''
          Host ${vars.generators.yggdrasil.files.address.value}
            User root
            IdentityFile ~/${secrets."${name}-root-private-key".path}
            ProxyJump beanbag
        '') machines)}
      '';
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

    home.persistence.state.files = [ ".ssh/known_hosts" ];
  };
}
