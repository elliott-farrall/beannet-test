{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    networking.networkmanager.enable = true;

    environment.persistence.data.directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
