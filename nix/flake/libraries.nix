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

      accentToBase16 = accentName:
        let
          map = {
            red = "red";
            peach = "orange";
            yellow = "yellow";
            green = "green";
            teal = "cyan";
            blue = "blue";
            mauve = "magenta";
            flamingo = "brown";
          };
        in
        map.${accentName};

      mkDefaultApplications = app: mimes: genAttrs mimes (_mime: app);
    }
  );
}
