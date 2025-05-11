{ config, ... }:

{
  flake.clan.machines."soy" = { ... }: {
    imports = with config.flake.modules; [
      nixos."machines/_server"
      nixos."machines/soy"
    ];

    clan.core.deployment.requireExplicitUpdate = true;
  };
}
