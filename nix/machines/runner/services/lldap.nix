{ ... }:

{
  flake.clan.machines."runner" = { lib, pkgs, config, ... }: {
    beannet.services."lldap" = {
      port = 17170;
    };

    services.traefik.dynamicConfigOptions = config.beannet.services."lldap".traefikConfig;

    services.lldap = {
      enable = true;

      settings = {
        http_url = config.beannet.services."lldap".href;
        http_port = config.beannet.services."lldap".port;

        ldap_port = config.beannet.ports.ldap;

        ldap_base_dn = lib.concatMapStringsSep "," (d: "dc=${d}") (lib.splitString "." config.beannet.domain);
        ldap_user_email = "${config.services.lldap.settings.ldap_user_dn}@${config.beannet.domain}";
      };

      environment = {
        LLDAP_JWT_SECRET_FILE = "%d/jwt-secret";
        LLDAP_KEY_SEED = "%d/key-seed";
        LLDAP_LDAP_USER_PASS_FILE = "%d/password";
      };
    };
    systemd.services.lldap.serviceConfig.LoadCredential = [
      "jwt-secret:${config.clan.core.vars.generators."ldap".files."jwt-secret".path}"
      "key-seed:${config.clan.core.vars.generators."ldap".files."key-seed".path}"
      "password:${config.clan.core.vars.generators."ldap".files."password".path}"
    ];

    clan.core.vars.generators."ldap" = {
      files."jwt-secret" = { };
      files."key-seed" = { secret = false; };
      files."password" = { };

      prompts."password-input" = {
        description = "LDAP admin password";
        type = "hidden";
        persist = false;
      };

      script = ''
        openssl rand -hex 16 > $out/jwt-secret
        openssl rand -hex 6 > $out/key-seed
        cat $prompts/password-input > $out/password
      '';
      runtimeInputs = with pkgs; [ openssl ];
    };

    preservation.preserveAt."/persist".files = [{ file = "/var/lib/lldap/users.db"; how = "symlink"; }];
  };
}
