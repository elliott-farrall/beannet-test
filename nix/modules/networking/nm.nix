{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    networking.networkmanager.enable = true;

    preservation.preserveAt.data.directories = [
      "/etc/NetworkManager/system-connections"
    ];
  };
}
