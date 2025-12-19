{ inputs, ... }:

{
  flake.lib = inputs.nixpkgs.lib.extend (final: _prev:
    let
      inherit (final)
        genAttrs
        ;
    in
    {
      inherit (inputs.home-manager.lib) hm;

      inherit (inputs.utils.lib)
        capitalise
        readYAML
        stripJSONC
        buildMustache
        ;

      mkDefaultApplications = app: mimes: genAttrs mimes (_mime: app);
    }
  );
}
