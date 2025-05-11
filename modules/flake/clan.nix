{ inputs, config, ... }:

{
  imports = with inputs; [ clan-core.flakeModules.default ];

  perSystem = { inputs', ... }: {
    make-shells.default.packages = with inputs'; [ clan-core.packages.clan-cli ];
  };

  clan = {
    meta.name = "beannet";
    specialArgs = { inherit (config.flake) lib; inherit inputs; };
  };
}
