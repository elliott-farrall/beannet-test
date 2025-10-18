{ inputs, ... }:

{
  imports = with inputs; [ git-hooks-nix.flakeModule ];

  perSystem = { pkgs, config, self', ... }: {
    make-shells."bean".inputsFrom = [ config.pre-commit.devShell ];

    pre-commit.settings = {
      excludes = [
        "sops.*$"
        "vars.*$"
        ".*facter\\.json$"
      ];

      hooks = {
        treefmt = {
          enable = true;
          package = self'.formatter;
        };

        # Nix
        nil.enable = true;
        flake-checker.enable = true;
        pre-commit-hook-ensure-sops.enable = true;

        # Config
        check-json.enable = true;
        check-yaml.enable = true;
        check-toml.enable = true;

        # Docs
        markdownlint.enable = true;
        check-vcs-permalinks.enable = true;

        # Git
        check-added-large-files.enable = true;

        # All
        editorconfig-checker.enable = true;
        end-of-file-fixer.enable = true;
        trim-trailing-whitespace.enable = true;
        ripsecrets.enable = true;

        flake = {
          enable = true;
          entry = "nix --extra-experimental-features 'nix-command flakes' flake lock";
          files = "^flake\\.lock$";
          pass_filenames = false;
          extraPackages = with pkgs; [ nix ];
        };

        renovate = {
          enable = true;
          entry = "renovate-config-validator";
          files = "renovate\\.json$";
          pass_filenames = false;
          extraPackages = with pkgs; [ renovate ];
        };
      };
    };
  };
}
