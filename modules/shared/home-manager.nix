{ inputs, config, ... }:

{
  imports = with inputs; [ home-manager.flakeModules.home-manager ];

  flake.modules.nixos."shared" = { lib, ... }: {
    imports = with inputs; [ home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit lib inputs; };
      sharedModules = with config.flake.modules; [ homeManager."shared" ];
    };
  };

  flake.modules.homeManager."shared" = { ... }: {
    programs.home-manager.enable = true;
  };
}
