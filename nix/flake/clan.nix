{ lib, inputs, config, withSystem, ... }:

{
  imports = with inputs; [ clan-core.flakeModules.default ];

  perSystem = { inputs', ... }: {
    make-shells."bean".packages = with inputs'.clan-core.packages; [
      clan-app
      clan-cli
      clan-vm-manager # Seems broken
      editor # Check nix language sever settings here, might be useful
    ];
  };

  flake.clan = {
    meta.name = "beans";
    pkgsForSystem = system: withSystem system (builtins.getAttr "pkgs");
    specialArgs = { inherit (config.flake) lib; inherit (inputs) self; };

    inventory.tags = {
      installer = [ "kidney" ];
      laptop = [ "lima" ];
      server = [ "runner" "sprout" "broad" ];
      wsl = [ "soy" ];
    };
  };

  # TODO - Come up with better fix for pkgs inheritance
  flake.nixosConfigurations = lib.mkForce inputs.self.clanInternals.machines.x86_64-linux;
}
