{ inputs, config, ... }:

{
  imports = with inputs; [ home-manager.flakeModules.home-manager ];

  flake.modules.nixos.default = { ... }: {
    imports = with inputs; [ home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      sharedModules = with config.flake.modules.homeManager; [ default ];
      backupFileExtension = "hmbak";
    };
  };

  flake.modules.homeManager.default = { ... }: {
    programs.home-manager.enable = true;
  };
}
