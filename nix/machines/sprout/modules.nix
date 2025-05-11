{ config, ... }:

{
  flake.clan.machines."sprout" = { ... }: {
    imports = with config.flake.modules; [
      nixos."default"
      nixos."shell/zsh"
    ];
  };
}
