{ ... }:

{
  flake.modules.nixos."machines/sprout" = { config, ... }: {
    sops.templates."pap-secrets".content = ''
      ${config.sops.placeholder.isp_username} * ${config.sops.placeholder.isp_password}
    '';
    environment.etc = {
      "ppp/pap-secrets" = {
        source = config.sops.templates."pap-secrets".path;
        mode = "0600";
      };
      "ppp/chap-secrets" = {
        source = config.sops.templates."pap-secrets".path;
        mode = "0600";
      };
    };

    sops.templates."peers/isp".content = ''
      plugin pppoe.so ont
      ifname wan

      name "${config.sops.placeholder.isp_username}"
      mtu 1492

      defaultroute
    '';
    services.pppd = {
      enable = true;
      peers."isp".config = config.sops.templates."peers/isp".path;
    };
  };
}
