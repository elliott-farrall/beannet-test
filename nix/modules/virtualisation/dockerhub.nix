{ ... }:

{
  flake.modules.nixos."default" = { lib, pkgs, config, ... }:
    let
      mkLoginService = backend: {
        description = "${lib.capitalise backend} Login Service";
        after = [ "network-online.target" ];
        requires = [ "network-online.target" ];

        path = [
          config.virtualisation.${backend}.package
          pkgs.toybox
        ];

        script = ''
          until ping -4qc 1 login.docker.com; do sleep 1; done
          cat ${config.sops.secrets."dockerhub_password".path} | ${backend} login --username $(cat ${config.sops.secrets."dockerhub_username".path}) --password-stdin
        '';

        wantedBy = [ "multi-user.target" ];
        serviceConfig.Restart = "on-failure";
      };
    in
    {
      systemd.services = {
        docker-login = lib.mkIf config.virtualisation.docker.enable (mkLoginService "docker");
        podman-login = lib.mkIf config.virtualisation.podman.enable (mkLoginService "podman");
      };
    };
}
