{ ... }:

{
  flake.modules.nixos."profiles/uos" = { lib, config, ... }: {
    networking.networkmanager.ensureProfiles = lib.mkIf config.networking.networkmanager.enable {
      environmentFiles = [ config.clan.core.vars.generators."uos".files."env".path ];
      profiles.eduroam = {
        connection = {
          id = "eduroam";
          uuid = "6f750d2a-845d-45e9-aa65-17a23736aff4";
          type = "wifi";
          permissions = "user:elliott:;";
        };
        wifi = {
          ssid = "eduroam";
        };
        wifi-security = {
          key-mgmt = "wpa-eap";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
        "802-1x" = {
          eap = "peap";
          identity = "$UOS_USERNAME";
          password = "$UOS_PASSWORD";
          phase2-auth = "mschapv2";
        };
      };
    };

    clan.core.vars.generators."uos" = {
      share = true;

      files."env" = { };

      prompts."email" = {
        description = "UoS email address";
      };
      prompts."password" = {
        description = "UoS password";
        type = "hidden";
      };

      script = ''
        cat <<EOF > $out/env
        UOS_USERNAME=$(cat $prompts/email)
        UOS_PASSWORD=$(cat $prompts/password)
        EOF
      '';
    };

  };
}
