{ lib, config, ... }:

let
  inherit (config.flake.clan) directory;
  inventory = config.flake.clan.inventory;

  domain = inventory.meta.domain;
  clanDir = directory;

  machines = lib.filterAttrs (_: m: m.machineClass == "nixos") inventory.machines;
  machineNames = lib.attrNames machines;

  rootPubKeyFile = name: "${clanDir}/vars/per-machine/${name}/sshd-root-key/id_ed25519.pub/value";
  rootPrivKeyFile = name: "${clanDir}/vars/per-machine/${name}/sshd-root-key/id_ed25519/secret";
  zerotierIpFile = name: "${clanDir}/vars/shared/zerotier-ip-${name}-zerotier/ip/value";
  yggdrasilAddrFile = name: "${clanDir}/vars/per-machine/${name}/yggdrasil/address/value";

  readFileMaybe = path:
    if builtins.pathExists path
    then lib.removeSuffix "\n" (builtins.readFile path)
    else "";

  rootPubKeys = lib.filter (k: k != "") (
    map (name: readFileMaybe (rootPubKeyFile name)) machineNames
  );
in
{
  flake.modules.nixos.default = { config, lib, ... }: {
    services.openssh.settings = {
      PermitRootLogin = lib.mkForce "prohibit-password";
      PasswordAuthentication = lib.mkForce false;
    };

    users.users.root.openssh.authorizedKeys.keys = rootPubKeys;

    programs.ssh.extraConfig =
      let
        identityFile = config.clan.core.vars.generators.sshd-root-key.files."id_ed25519".path;
      in
      ''
        Host beanbag
          Hostname ssh.${domain}
          User root
          IdentityFile ${identityFile}

        ${lib.concatLines (
          lib.concatMap (
            name:
            let
              hosts = [ "${name}.${domain}" ]
                ++ lib.optional (builtins.pathExists (zerotierIpFile name)) (readFileMaybe (zerotierIpFile name))
                ++ lib.optional (builtins.pathExists (yggdrasilAddrFile name)) (readFileMaybe (yggdrasilAddrFile name));
            in
            map (
              host: ''
                Host ${host}
                  User root
                  IdentityFile ${identityFile}
                  ProxyJump beanbag
              ''
            ) hosts
          ) machineNames
        )}
      '';

    services.fail2ban.enable = true;
  };

  flake.modules.homeManager.default = { config, lib, ... }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks =
        let
          inherit (config.sops) secrets;
        in
        { "*".userKnownHostsFile = "~/.ssh/hosts/known_hosts"; }
        // {
          beanbag = {
            hostname = "ssh.${domain}";
            user = "root";
            identityFile = "~/${secrets."runner-root-private-key".path}";
          };
        }
        // lib.listToAttrs (
          lib.concatMap (
            name:
            let
              identityFile = "~/${secrets."${name}-root-private-key".path}";
              hosts = [ "${name}.${domain}" ]
                ++ lib.optional (builtins.pathExists (zerotierIpFile name)) (readFileMaybe (zerotierIpFile name))
                ++ lib.optional (builtins.pathExists (yggdrasilAddrFile name)) (readFileMaybe (yggdrasilAddrFile name));
            in
            map (host: lib.nameValuePair host {
              user = "root";
              inherit identityFile;
              proxyJump = "beanbag";
            }) hosts
          ) machineNames
        );
    };

    sops.secrets = lib.listToAttrs (
      map (name: {
        name = "${name}-root-private-key";
        value = {
          sopsFile = rootPrivKeyFile name;
          path = ".ssh/credentials/${name}-root";
          format = "binary";
        };
      }) machineNames
    );

    home.persistence.state.directories = [ ".ssh/hosts" ];
  };
}
