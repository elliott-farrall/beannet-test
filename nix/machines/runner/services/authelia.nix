{ ... }:

{
  flake.clan.machines."runner" = { lib, pkgs, config, ... }:
    let
      zerotierIpPath = "${config.clan.core.settings.directory}/vars/shared/zerotier-ip-runner-zerotier/ip/value";
      zerotierIp = lib.optionalString (builtins.pathExists zerotierIpPath)
        (lib.removeSuffix "\n" (builtins.readFile zerotierIpPath));
      # Zerotier assigns IPv6 addresses in a /64 ULA derived from the network id.
      zerotierSubnet = lib.optionalString (zerotierIp != "")
        "${lib.concatStringsSep ":" (lib.take 4 (lib.splitString ":" zerotierIp))}::/64";
      # IPv4 assignment pool enabled in nix/machines/runner/services/zerotier.nix.
      zerotierIpv4Subnet = "10.147.17.0/24";
    in
    {
      beannet.services."authelia" = {
        port = 9091;
      };

      services.traefik.dynamicConfigOptions = lib.mkMerge [
        config.beannet.services."authelia".traefikConfig
        {
          http.middlewares."auth".forwardauth = {
            address = with config.beannet.services."authelia"; "${url}/api/verify?rd=${href}:${toString config.beannet.ports.auth}";
            trustForwardHeader = false;
            authResponseHeaders = [ "Remote-User" "Remote-Groups" "Remote-Name" "Remote-Email" ];
          };
          http.routers."authelia".entrypoints = [ "auth" ];
        }
      ];

      services.authelia.instances."auth" = {
        enable = true;

        settings = {
          server.address = "tcp://127.0.0.1:${toString config.beannet.services."authelia".port}/";

          access_control.rules =
            # Anything on the Clan Zerotier VPN reaches services without going
            # through the browser SSO flow. Requests from either the Zerotier
            # IPv6 ULA subnet or the Zerotier IPv4 assignment pool bypass
            # Authelia; everything else falls through to the standard one_factor
            # rule below.
            [
              {
                domain = [
                  config.beannet.domain
                  "*.${config.beannet.domain}"
                ];
                policy = "bypass";
                networks = [ zerotierIpv4Subnet ] ++ lib.optional (zerotierSubnet != "") zerotierSubnet;
              }
            ]
            ++ [
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
            address = "ldaps://${config.beannet.services."lldap".hostname}:${toString config.beannet.ports.ldaps}";
            tls = {
              skip_verify = true;
            };
            base_dn = config.services.lldap.settings.ldap_base_dn;
            user = "uid=${config.services.lldap.settings.ldap_user_dn},ou=people,${config.services.lldap.settings.ldap_base_dn}";
          };

          storage.local.path = "/var/lib/authelia-auth/db-v2.sqlite3";

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
        files."jwt-secret".secret = true;
        files."session-secret".secret = true;
        files."storage-key".secret = true;

        script = ''
          openssl rand -hex 32 > $out/jwt-secret
          openssl rand -hex 32 > $out/session-secret
          openssl rand -hex 32 > $out/storage-key
        '';
        runtimeInputs = with pkgs; [ openssl ];
      };

      environment.persistence.state.directories = [
        "/var/lib/authelia-auth"
      ];
    };
}
