{ ... }:

{
  flake.modules.nixos.default = { config, lib, ... }: {
    environment.persistence.state.directories = lib.mkIf config.networking.networkmanager.enable [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
