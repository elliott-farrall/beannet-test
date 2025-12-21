{ inputs, ... }:

{
  imports = with inputs; [ treefmt-nix.flakeModule ];

  perSystem = { ... }: {
    treefmt = {
      settings.global.excludes = [
        "sops/**"
        "vars/**"
        "**/facter.json"
        "inventory.json"
      ];

      programs = {
        # Nix
        nixpkgs-fmt.enable = true;
        statix.enable = true;
        deadnix.enable = true;
        nixf-diagnose.enable = true;

        statix.disabled-lints = [ "empty_pattern" "repeated_keys" ];

        # Config
        jsonfmt.enable = true;
        yamlfmt.enable = true;
        taplo.enable = true;
        actionlint.enable = true;

        # Docs
        mdformat.enable = true;
        # typos.enable = true;
        autocorrect.enable = true;
      };
    };
  };
}
