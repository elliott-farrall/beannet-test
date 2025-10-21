{ config, ... }:

{
  flake.clan.machines."broad" = { ... }: {
    imports = with config.flake.modules; [
      nixos."default"
      nixos."shell/zsh"
    ];
  };
}
