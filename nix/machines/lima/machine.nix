{ config, ... }:

{
  flake.clan.machines."lima" = { ... }: {
    imports = with config.flake.modules; [
      nixos."default"
      nixos."shell/zsh"
      nixos."users/elliott"
    ];

    clan.core.deployment.requireExplicitUpdate = true;
  };
}
