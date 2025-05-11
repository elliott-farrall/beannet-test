{ ... }:

{
  flake.clan.machines."sprout" = { lib, config, ... }: {
    services.pppd = {
      enable = true;
      peers."isp".enable = true;
    };

    environment.etc = {
      "ppp/peers/isp".source = lib.mkForce config.clan.core.vars.generators."isp".files."config".path;
      "ppp/pap-secrets".source = lib.mkForce config.clan.core.vars.generators."isp".files."secrets".path;
    };

    clan.core.vars.generators."isp" = {
      files."config" = { };
      files."secrets" = { };

      prompts."username" = {
        description = "ISP username";
        type = "hidden";
      };
      prompts."password" = {
        description = "ISP password";
        type = "hidden";
      };

      script = ''
        cat <<EOF > $out/config
        plugin pppoe.so ont
        ifname wan

        name "$(cat $prompts/username)"
        mtu 1492

        defaultroute
        EOF

        cat <<EOF > $out/secrets
        $(cat $prompts/username) * $(cat $prompts/password)
        EOF
      '';
    };
  };
}
