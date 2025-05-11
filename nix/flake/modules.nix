{ inputs, config, ... }:

{
  imports = with inputs; [ flake-parts.flakeModules.modules ];

  flake = with config.flake.modules; {
    nixosModules = nixos;
    homeModules = homeManager;
  };
}
