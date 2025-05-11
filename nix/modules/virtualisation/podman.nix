{ ... }:

{
  flake.modules.nixos."default" = { config, ... }: {
    virtualisation.podman.dockerSocket = { inherit (config.virtualisation.podman) enable; };
  };
}
