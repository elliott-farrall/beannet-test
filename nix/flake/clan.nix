{ lib, inputs, config, withSystem, ... }:

{
  imports = with inputs; [ clan-core.flakeModules.default ];

  perSystem = { inputs', ... }: {
    make-shells.default.packages = with inputs'.clan-cli.packages; [ clan-cli clan-app ];
  };

  clan = {
    meta.name = "beannet";
    pkgsForSystem = system: withSystem system (builtins.getAttr "pkgs");
    specialArgs = { inherit (config.flake) lib modules; };

    templates.disko = {
      zfs = {
        description = "ZFS with EFI support for impermenant setups";
        path = ../../templates/disk/zfs;
      };
    };
  };

  # TODO - Come up with better fix for pkgs inheritance
  flake.nixosConfigurations = lib.mkForce inputs.self.clanInternals.machines.x86_64-linux;
}
