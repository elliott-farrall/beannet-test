{ lib, config, ... }:

let
  inherit (config.flake.clan) directory;
  inherit (config.flake.clan.inventory.meta) domain;
  inherit (lib)
    attrNames
    concatStringsSep
    filterAttrs
    hasInfix
    listToAttrs
    mapAttrsToList
    nameValuePair
    optional
    ;

  bracketIpv6 = addr: if hasInfix ":" addr && !(hasInfix "." addr) then "[${addr}]" else addr;

  machineNames = attrNames (filterAttrs (_: m: m.machineClass == "nixos") config.flake.clan.inventory.machines);

  rootPubKeys = map
    (name: lib.removeSuffix "\n" (builtins.readFile "${directory}/vars/per-machine/${name}/sshd-root-key/id_ed25519.pub/value"))
    machineNames;

  optionalValue = path: lib.optional (builtins.pathExists path) (lib.removeSuffix "\n" (builtins.readFile path));

  machineHostPubKey = name: optionalValue "${directory}/vars/per-machine/${name}/openssh/ssh.id_ed25519.pub/value";

  machineHostPatterns = name:
    optionalValue "${directory}/vars/shared/zerotier-ip-${name}-zerotier/ip/value"
    ++ optionalValue "${directory}/vars/per-machine/${name}/yggdrasil/address/value";

  hostPatterns = name:
    [ name "${name}.${domain}" ]
    ++ optionalValue "${directory}/vars/shared/zerotier-ip-${name}-zerotier/ip/value"
    ++ optionalValue "${directory}/vars/per-machine/${name}/yggdrasil/address/value";

  sshHosts = { jumpKey, hostKeys }: {
    beanbag = {
      hostname = "ssh.${domain}";
      hostKeyAlias = "runner.${domain}";
      user = "root";
      identityFile = jumpKey;
    };
  } // listToAttrs (
    map
      (name: nameValuePair (concatStringsSep " " (hostPatterns name)) {
        user = "root";
        hostname = lib.head (machineHostPatterns name ++ [ "${name}.${domain}" ]);
        identityFile = hostKeys.${name};
        proxyJump = "beanbag";
        hostKeyAlias = "${name}.${domain}";
      })
      machineNames
  );

  renderHosts = hosts: concatStringsSep "\n\n" (
    mapAttrsToList
      (name: opts: concatStringsSep "\n" (
        [ "Host ${name}" ]
        ++ optional (opts.hostname or null != null) "  Hostname ${opts.hostname}"
        ++ optional (opts.hostKeyAlias or null != null) "  HostKeyAlias ${opts.hostKeyAlias}"
        ++ [ "  User ${opts.user}" ]
        ++ [ "  IdentityFile ${opts.identityFile}" ]
        ++ optional (opts.proxyJump or null != null) "  ProxyJump ${opts.proxyJump}"
      ))
      hosts
  );
in
{
  flake.modules.nixos.default = { config, ... }: {
    services.openssh.settings = {
      PermitRootLogin = lib.mkForce "prohibit-password";
      PasswordAuthentication = lib.mkForce false;
    };

    users.users.root.openssh.authorizedKeys.keys = rootPubKeys;

    programs.ssh = {
      knownHosts = lib.listToAttrs (
        map
          (name: lib.nameValuePair "clan-${name}" {
            hostNames = map bracketIpv6 (machineHostPatterns name) ++ lib.optional (name == "runner") "ssh.${domain}";
            publicKey = lib.head (machineHostPubKey name);
          })
          (lib.filter (name: machineHostPubKey name != [ ]) machineNames)
      );

      extraConfig = renderHosts (sshHosts {
        jumpKey = config.clan.core.vars.generators.sshd-root-key.files."id_ed25519".path;
        hostKeys = lib.genAttrs machineNames (_: config.clan.core.vars.generators.sshd-root-key.files."id_ed25519".path);
      });
    };

    services.fail2ban.enable = true;
  };

  flake.modules.homeManager.default = { config, ... }: {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      settings = sshHosts {
        jumpKey = "~/${config.sops.secrets."runner-root-private-key".path}";
        hostKeys = lib.genAttrs machineNames (name: "~/${config.sops.secrets."${name}-root-private-key".path}");
      };
    };

    sops.secrets = listToAttrs (
      map
        (name: {
          name = "${name}-root-private-key";
          value = {
            sopsFile = "${directory}/vars/per-machine/${name}/sshd-root-key/id_ed25519/secret";
            path = ".ssh/credentials/${name}-root";
            format = "binary";
          };
        })
        machineNames
    );
  };
}
