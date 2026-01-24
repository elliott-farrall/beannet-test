{ inputs, ... }:

{
  flake.modules.nixos.default = { pkgs, ... }:
    let
      lidm = inputs.lidm.defaultPackage.${pkgs.system}.override (attrs: {
        config = attrs.config // { cfg = "nord"; };
      });
    in
    {
      # FIXME - Need custom login config for kmscon
      disabledModules = [ "services/ttys/kmscon.nix" ];
      imports = [ ./_overrides/kmscon.nix ];

      services.kmscon = {
        enable = true;
        hwRender = true;

        extraConfig = ''
          login=${lidm}/bin/lidm
        '';
      };
    };
}
