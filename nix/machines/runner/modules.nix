{ config, ... }:

{
  clan.machines."runner" = { ... }: {
    imports = with config.flake.modules; [
      nixos."default"
      nixos."shell/zsh"
    ];
  };
}
