{ config, ... }:

{
  flake.clan.machines."broad" = { ... }: {
    imports = with config.flake.modules; [
      nixos."machines/_server"
    ];
  };
}
