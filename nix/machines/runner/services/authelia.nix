{ ... }:

{
  flake.modules.nixos."machines/runner" = { lib, pkgs, config, ... }: {
    beannet.services."authelia" = {
      port = 9091;
    };

    services.traefik.dynamicConfigOptions = lib.mkMerge [
      config.beannet.services."authelia".traefikConfig
      {
        http.middlewares."auth".forwardauth = {
          address = with config.beannet.services."authelia"; "${url}/api/verify?rd=${href}:${toString config.beannet.ports.auth}";
          trustForwardHeader = true;
          authResponseHeaders = [ "Remote-User" "Remote-Groups" "Remote-Name" "Remote-Email" ];
        };
        http.routers."authelia".entrypoints = [ "auth" ];
      }
    ];

    services.authelia.instances."auth" = {
      enable = true;

      settings = {
        access_control.rules = [
          {
            domain = [
              config.beannet.domain
              "*.${config.beannet.domain}"
            ];
            policy = "one_factor";
            subject = "group:lldap_admin";
          }
        ];

        authentication_backend.ldap = {
          implementation = "lldap";
          address = "ldap://${config.beannet.services."lldap".hostname}:${toString config.beannet.ports.ldap}";
          base_dn = config.services.lldap.settings.ldap_base_dn;
          user = "uid=${config.services.lldap.settings.ldap_user_dn},ou=people,${config.services.lldap.settings.ldap_base_dn}";
        };

        storage.local.path = "/var/lib/authelia-auth/db.sqlite3";

        notifier.filesystem.filename = "/var/lib/authelia-auth/notification.txt";

        session.cookies = [
          {
            inherit (config.beannet) domain;
            authelia_url = config.beannet.services."authelia".href;
            default_redirection_url = config.beannet.href;
          }
        ];
      };

      environmentVariables = {
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = "%d/ldap-password";
        AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET_FILE = "%d/jwt-secret";
        AUTHELIA_SESSION_SECRET_FILE = "%d/session-secret";
        AUTHELIA_STORAGE_ENCRYPTION_KEY_FILE = "%d/storage-key";
      };
      secrets.manual = true;
    };
    systemd.services.authelia-auth.serviceConfig.LoadCredential = [
      "ldap-password:${config.clan.core.vars.generators."ldap".files."password".path}"
      "jwt-secret:${config.clan.core.vars.generators."auth".files."jwt-secret".path}"
      "session-secret:${config.clan.core.vars.generators."auth".files."session-secret".path}"
      "storage-key:${config.clan.core.vars.generators."auth".files."storage-key".path}"
    ];

    clan.core.vars.generators."auth" = {
      files."jwt-secret" = { };
      files."session-secret" = { };
      files."storage-key" = { };

      script = ''
        openssl rand -hex 32 > $out/jwt-secret
        openssl rand -hex 32 > $out/session-secret
        openssl rand -hex 32 > $out/storage-key
      '';
      runtimeInputs = with pkgs; [ openssl ];
    };

    preservation.preserveAt.state.directories = [
      "/var/lib/authelia-auth"
    ];
  };
}
