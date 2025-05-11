{ ... }:

{
  flake.modules.nixos."shared" = { config, ... }: {
    virtualisation.podman.dockerSocket = { inherit (config.virtualisation.podman) enable; };
  };
}
