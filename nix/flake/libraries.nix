{ inputs, ... }:

{
  flake.lib = inputs.nixpkgs.lib.extend (final: _prev:
    let
      inherit (final)
        genAttrs
        stringLength
        substring
        toUpper
        ;
    in
    {
      inherit (inputs.home-manager.lib) hm;

      capitalise = str: (toUpper (substring 0 1 str)) + (substring 1 (stringLength str) str);

      mkDefaultApplications = app: mimes: genAttrs mimes (_mime: app);
    }
  );
}
