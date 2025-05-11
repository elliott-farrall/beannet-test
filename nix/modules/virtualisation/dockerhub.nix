{ ... }:

{
  flake.modules.nixos."default" = { lib, pkgs, config, ... }:
    let
      inherit (config.clan.core.vars.generators."dockerhub") files;

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
          cat ${files."password".path} | ${backend} login --username $(cat ${files."username".path}) --password-stdin
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

      clan.core.vars.generators."dockerhub" = {
        share = true;

        prompts."username" = {
          description = "DockerHub username";
          persist = true;
        };
        prompts."password" = {
          description = "DockerHub password";
          type = "hidden";
          persist = true;
        };
      };
    };
}
