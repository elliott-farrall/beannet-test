{ inputs, ... }:

{
  flake.modules.nixos.default = { lib, config, ... }: {
    options = {
      applications.vscode.enable = lib.mkEnableOption "the Visual Studio Code application";
    };

    config = lib.mkIf config.applications.vscode.enable {
      nixpkgs.overlays = with inputs; [
        code-insiders.overlays.default
        nix-vscode-extensions.overlays.default
      ];
    };
  };

  flake.modules.homeManager.default = { lib, pkgs, config, ... }:
    let
      inherit (config.catppuccin) flavor;

      mkSettings = file: data: builtins.fromJSON (
        lib.buildMustache "vscode-settings.json"
          (
            lib.stripJSONC (builtins.readFile file)
          )
          data
      );
    in
    {
      options = {
        applications.vscode.enable = lib.mkEnableOption "the Visual Studio Code application";
      };

      config = lib.mkIf config.applications.vscode.enable {
        programs.vscode = {
          enable = true;
          package = pkgs.vscode-insiders;
          mutableExtensionsDir = false;

          profiles.default = {
            enableExtensionUpdateCheck = false;

            extensions = builtins.map
              (ext:
                let
                  author = builtins.elemAt (lib.splitString "." ext) 0;
                  name = builtins.elemAt (lib.splitString "." ext) 1;
                in
                pkgs.vscode-marketplace.${author}.${name})
              (lib.readYAML ./editor/extensions.yaml);

            userSettings = lib.mkMerge [
              (mkSettings ./editor/settings.jsonc {
                gh_repo_dir = "${config.xdg.userDirs.extraConfig.XDG_REPO_DIR}/gh_repositories";
              })
              {
                "workbench.colorTheme" = lib.mkForce "Catppuccin ${lib.capitalise flavor}";
              }
            ];
          };
        };

        home.sessionVariables = {
          EDITOR = "code-insiders -w";
          VISUAL = "code-insiders -w";
        };

        xdg.mimeApps.defaultApplications = lib.mkMerge [
          lib.mkDefaultApplications
          "code-insiders.desktop"
          builtins.fromJSON.associations.json.editor
          lib.mkDefaultApplications
          "code-insiders-url-handler.desktop"
          builtins.fromJSON.associations.json.editor-url
        ];

        desktop.wmIcons."code-insiders" = "󰨞";

        home.persistence.state = {
          directories = [ ".config/Code - Insiders" ];
          files = [ ".vscode-insiders/argv.json" ];
        };
      };
    };
}
