{ inputs, config, withSystem, ... }:

{
  imports = with inputs; [ clan-core.flakeModules.default ];

  perSystem = { pkgs, inputs', ... }: {
    legacyPackages.runner.install = pkgs.writeShellScriptBin "runner-install" ''
      exec ${inputs'.clan-core.packages.clan-cli}/bin/clan machines install runner "$@"
    '';

    legacyPackages.runner.update = pkgs.writeShellScriptBin "runner-update" ''
      exec ${inputs'.clan-core.packages.clan-cli}/bin/clan machines update runner "$@"
    '';

    make-shells."bean".packages = with inputs'.clan-core.packages; [
      clan-cli
      editor # Check nix language sever settings here, might be useful
    ];
  };

  flake.clan = {
    meta = {
      name = "beans";
      domain = "bean.directory";
    };

    pkgsForSystem = system: withSystem system ({ pkgs, ... }: pkgs);
    specialArgs = { inherit (config.flake) lib; inherit (inputs) self; };

    inventory.tags = {
      installer = [ "kidney" ];
      laptop = [ "lima" ];
      server = [ "runner" "sprout" "broad" ];
      wsl = [ "soy" ];
    };
  };


}
