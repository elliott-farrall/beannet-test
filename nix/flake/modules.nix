{ inputs, config, ... }:

{
  imports = with inputs; [ flake-parts.flakeModules.modules ];

  flake = with config.flake.modules; {
    nixosModules = nixos;
    homeModules = homeManager;

    clan.outputs.moduleForMachine = with nixos; {
      broad = default;
      kidney = default;
      lima = default;
      runner = default;
      soy = default;
      sprout = default;
    };
  };
}
