{ config, ... }:

{
  flake.modules.nixos."machines/_server" = { ... }: {
    imports = with config.flake.modules; [
      nixos."default"
      nixos."shell/zsh"
    ];
  };
}
