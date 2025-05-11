{ config, ... }:

{
  flake.modules.nixos."machines/sprout" = { ... }: {
    imports = with config.flake.modules; [
      nixos."shared"
      nixos."users/root"
      nixos."users/elliott" # testing
    ];
  };
}
