{ inputs, ... }:

{
  imports = with inputs; [ treefmt-nix.flakeModule ];

  perSystem = { ... }: {
    treefmt = {
      settings.global.excludes = [
        "sops/**"
        "vars/**"
        "**/facter.json"
      ];

      programs = {
        # Nix
        deadnix.enable = true;
        nixf-diagnose.enable = true;
        nixpkgs-fmt.enable = true;
        statix.enable = true;

        statix.disabled-lints = [ "empty_pattern" "repeated_keys" ];

        # Docs
        autocorrect.enable = true;
        mdformat.enable = true;
        typos.enable = true;
      };
    };
  };
}
