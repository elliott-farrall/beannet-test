{ config, ... }:

{
  flake.clan.machines."lima" = { ... }: {
    imports = with config.flake.modules; [
      nixos."machines/_workstation"
    ];

    clan.core.deployment.requireExplicitUpdate = true;
  };
}
