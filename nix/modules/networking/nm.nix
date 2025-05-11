{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    networking.networkmanager.enable = true;
  };
}
