{ lib, inputs, config, withSystem, ... }:

{
  imports = with inputs; [ clan-core.flakeModules.default ];

  perSystem = { inputs', ... }: {
    make-shells."beannet".packages = with inputs'.clan-core.packages; [
      clan-app
      clan-cli
      clan-vm-manager # Seems broken
      editor # Check nix language sever settings here, might be useful
    ];
  };

  flake.clan = {
    meta.name = "beannet";
    pkgsForSystem = system: withSystem system (builtins.getAttr "pkgs");
    specialArgs = { inherit (config.flake) lib; inherit (inputs) self; };
  };

  # TODO - Come up with better fix for pkgs inheritance
  flake.nixosConfigurations = lib.mkForce inputs.self.clanInternals.machines.x86_64-linux;
}
