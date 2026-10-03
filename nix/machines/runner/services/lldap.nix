{ ... }:

{
  flake.clan.machines."runner" = { lib, pkgs, config, ... }: {
    beannet.services."lldap" = {
      port = 17170;
    };

    services.traefik.dynamicConfigOptions = config.beannet.services."lldap".traefikConfig;

    services.lldap = {
      enable = true;
      silenceForceUserPassResetWarning = true;

      settings = {
        http_url = config.beannet.services."lldap".href;
        http_port = config.beannet.services."lldap".port;

        ldap_host = "127.0.0.1";
        ldap_port = config.beannet.ports.ldap;

        ldaps_options = {
          enabled = true;
          port = config.beannet.ports.ldaps;
          cert_file = "/var/lib/private/lldap/cert.pem";
          key_file = "/var/lib/private/lldap/key.pem";
        };

        ldap_base_dn = lib.concatMapStringsSep "," (d: "dc=${d}") (lib.splitString "." config.beannet.domain);
        ldap_user_email = "admin@${config.beannet.domain}";
      };

      environment = {
        LLDAP_JWT_SECRET_FILE = "%d/jwt-secret";
        LLDAP_KEY_SEED_FILE = "%d/key-seed";
        LLDAP_LDAP_USER_PASS_FILE = "%d/password";
      };
    };
    systemd.services.lldap.serviceConfig.LoadCredential = [
      "jwt-secret:${config.clan.core.vars.generators."ldap".files."jwt-secret".path}"
      "key-seed:${config.clan.core.vars.generators."ldap".files."key-seed".path}"
      "password:${config.clan.core.vars.generators."ldap".files."password".path}"
    ];

    clan.core.vars.generators."ldap" = {
      files."jwt-secret".secret = true;
      files."key-seed".secret = true;

      prompts."password" = {
        description = "LDAP admin password";
        type = "hidden";
        persist = true;
      };

      script = ''
        openssl rand -hex 16 > $out/jwt-secret
        openssl rand -hex 6 > $out/key-seed
      '';
      runtimeInputs = with pkgs; [ openssl ];
    };

    environment.persistence.data.directories = [
      { directory = "/var/lib/private/lldap"; mode = "0700"; }
    ];

    system.activationScripts.lldap-var-lib-private = ''
      mkdir -p /var/lib/private
      chmod 0700 /var/lib/private
      mkdir -p /var/lib/private/lldap
      if [ ! -f /var/lib/private/lldap/cert.pem ] || [ ! -f /var/lib/private/lldap/key.pem ]; then
        ${pkgs.openssl}/bin/openssl req -x509 \
          -newkey rsa:2048 \
          -keyout /var/lib/private/lldap/key.pem \
          -out /var/lib/private/lldap/cert.pem \
          -days 3650 \
          -nodes \
          -subj "/CN=lldap" \
          -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
      fi
      # The dynamic lldap user must be able to read these; the directory is
      # 0700 so world-readable files are still only accessible to root/lldap.
      chmod 0644 /var/lib/private/lldap/cert.pem /var/lib/private/lldap/key.pem
    '';

    systemd.services.lldap.serviceConfig = {
      StateDirectoryMode = lib.mkForce "0700";
    };
  };
}
