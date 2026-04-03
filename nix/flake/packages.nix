{ inputs, ... }:

{
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.allowDeprecatedx86_64Darwin = true;
      overlays = [ ];
    };
  };
}
