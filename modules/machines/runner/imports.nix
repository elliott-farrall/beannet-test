{ config, ... }:

{
  flake.modules.nixos."machines/runner" = { ... }: {
    imports = with config.flake.modules; [
      nixos."shared"
      nixos."users/root"
    ];
  };
}
