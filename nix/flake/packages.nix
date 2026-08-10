{ inputs, ... }:

{
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.allowDeprecatedx86_64Darwin = true;
      overlays = [
        (_final: prev: {
          opencode = prev.opencode.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              ../modules/ai/opencode.patch
            ];
          });
        })
      ];
    };
  };
}
