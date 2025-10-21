{ config, ... }:

{
  flake.clan.machines."soy" = { ... }: {
    imports = with config.flake.modules; [
      nixos."default"
      nixos."shell/zsh"
    ];

    clan.core.deployment.requireExplicitUpdate = true;
  };
}
