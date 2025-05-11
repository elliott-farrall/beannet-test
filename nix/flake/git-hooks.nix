{ inputs, ... }:

{
  imports = with inputs; [ git-hooks-nix.flakeModule ];

  perSystem = { pkgs, config, ... }: {
    make-shells.default.inputsFrom = [ config.pre-commit.devShell ];

    pre-commit.settings = {
      excludes = [
        "sops.*$"
        "vars.*$"
        ".*facter\\.json$"
        ".*\\.hash$"
        ".*\\.ppd$"
      ];

      hooks = {

        /* --------------------------------- Editor --------------------------------- */

        editorconfig-checker.enable = true;
        end-of-file-fixer.enable = true;
        trim-trailing-whitespace.enable = true;

        /* --------------------------------- Checks --------------------------------- */

        nil.enable = true;
        check-json.enable = true;
        check-toml.enable = true;
        check-yaml.enable = true;

        check-executables-have-shebangs.enable = true;
        check-shebang-scripts-are-executable.enable = true;

        check-python.enable = true;
        check-builtin-literals.enable = true;
        check-docstring-first.enable = true;

        /* ----------------------------------- Git ---------------------------------- */

        convco.enable = true;
        check-added-large-files = {
          enable = true;
          excludes = [ "\\wallpaper.jpg" ];
        };
        check-vcs-permalinks.enable = true;
        detect-private-keys.enable = true;
        forbid-new-submodules.enable = true;

        /* --------------------------------- Custom --------------------------------- */

        # act = {
        #   enable = false; #TODO - Fix act pre-commit
        #   entry = "act -nW";
        #   files = "^\\.github/workflows/.*\\.yaml$";
        #   extraPackages = with pkgs; [ act ];
        # };

        # compose2nix = {
        #   enable = true;
        #   entry = "find systems -type f -path systems/*/*/**/compose.sh -exec {} \\;";
        #   files = "compose\\.yaml$";
        #   pass_filenames = false;
        # };

        lock-flake = {
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
