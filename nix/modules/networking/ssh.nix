{ lib, config, ... }:

let
  clanDir = config.flake.clan.directory;
  domain = config.flake.clan.inventory.meta.domain;

  machines = lib.filterAttrs (_: m: m.machineClass == "nixos") config.flake.clan.inventory.machines;
  machineNames = lib.attrNames machines;

  rootPubKeyFile = name: "${clanDir}/vars/per-machine/${name}/sshd-root-key/id_ed25519.pub/value";
  rootPrivKeyFile = name: "${clanDir}/vars/per-machine/${name}/sshd-root-key/id_ed25519/secret";
  zerotierIpFile = name: "${clanDir}/vars/shared/zerotier-ip-${name}-zerotier/ip/value";
  yggdrasilAddrFile = name: "${clanDir}/vars/per-machine/${name}/yggdrasil/address/value";

  readValue = path: lib.removeSuffix "\n" (builtins.readFile path);
  optionalValue = path: if builtins.pathExists path then [ (readValue path) ] else [ ];
  readValueMaybe = path: if builtins.pathExists path then readValue path else null;

  rootPubKeys = lib.filter (k: k != null) (map (name: readValueMaybe (rootPubKeyFile name)) machineNames);

  hostEntries =
    [{ host = "beanbag"; hostname = "ssh.${domain}"; keyName = "runner"; proxy = false; }]
    ++ lib.concatMap
      (name:
        let
          hosts = [ "${name}.${domain}" ]
          ++ optionalValue (zerotierIpFile name)
          ++ optionalValue (yggdrasilAddrFile name);
        in
        map (host: { inherit host; keyName = name; proxy = true; }) hosts
      )
      machineNames;
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

        hostLines = h: [
          "Host ${h.host}"
          "  User root"
        ]
        ++ lib.optional (h.hostname or null != null) "  Hostname ${h.hostname}"
        ++ [
          "  IdentityFile ${identityFile}"
        ]
        ++ lib.optional h.proxy "  ProxyJump beanbag";
      in
      lib.concatLines (lib.concatMap hostLines hostEntries);

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
        // lib.listToAttrs (map
          (h: lib.nameValuePair h.host ({
            user = "root";
            identityFile = "~/${secrets."${h.keyName}-root-private-key".path}";
          }
          // lib.optionalAttrs (h.hostname or null != null) { inherit (h) hostname; }
          // lib.optionalAttrs h.proxy { proxyJump = "beanbag"; }))
          hostEntries);
    };

    sops.secrets = lib.listToAttrs (
      map
        (name: {
          name = "${name}-root-private-key";
          value = {
            sopsFile = rootPrivKeyFile name;
            path = ".ssh/credentials/${name}-root";
            format = "binary";
          };
        })
        machineNames
    );

    home.persistence.state.directories = [ ".ssh/hosts" ];
  };
}
