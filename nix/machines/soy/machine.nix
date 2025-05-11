{ config, ... }:

{
  flake.clan.machines."soy" = { ... }: {
    imports = with config.flake.modules; [
      nixos."machines/_server"
    ];

    clan.core.deployment.requireExplicitUpdate = true;
  };
}
