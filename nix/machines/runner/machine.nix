{ config, ... }:

{
  flake.clan.machines."runner" = { ... }: {
    imports = with config.flake.modules; [
      nixos."machines/_server"
      nixos."machines/runner"
    ];
  };
}
