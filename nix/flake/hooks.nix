{ inputs, ... }:

{
  imports = with inputs; [ git-hooks-nix.flakeModule ];

  perSystem = { config, self', ... }: {
    make-shells."bean".inputsFrom = [ config.pre-commit.devShell ];

    pre-commit.settings = {
      excludes = [
        "sops.*$"
        "vars.*$"
        ".*facter\\.json$"
        "inventory.json"
      ];

      hooks = {
        treefmt = {
          enable = true;
          package = self'.formatter;
        };

        # Nix
        nil.enable = true;
        flake-checker.enable = false;
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
      };
    };
  };
}
