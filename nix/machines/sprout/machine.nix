{ config, ... }:

{
  flake.clan.machines."sprout" = { lib, ... }: {
    imports = with config.flake.modules; [
      nixos."default"
      nixos."shell/zsh"
      nixos."machines/sprout"
    ];

    networking.networkmanager.enable = lib.mkForce false;
  };
}
