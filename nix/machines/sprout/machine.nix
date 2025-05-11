{ config, ... }:

{
  flake.clan.machines."sprout" = { lib, ... }: {
    imports = with config.flake.modules; [
      nixos."machines/_server"
      nixos."machines/sprout"
    ];

    networking.networkmanager.enable = lib.mkForce false;
  };
}
