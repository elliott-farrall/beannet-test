{ ... }:

{
  flake.modules.nixos."default" = { lib, config, ... }: {
    environment.persistence.state.directories = lib.mkIf config.services.fprintd.enable [ "/var/lib/fprint" ];
  };
}
