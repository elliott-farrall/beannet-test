{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    networking.networkmanager.enable = true;

    environment.persistence.state.directories = [ "/etc/NetworkManager/system-connections" ];
  };
}
