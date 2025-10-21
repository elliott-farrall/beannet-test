{ inputs, ... }:

{
  flake.modules.nixos."programs/vscode" = { ... }: {
    nixpkgs.overlays = with inputs; [
      code-insiders.overlays.default
      nix-vscode-extensions.overlays.default
      nix4vscode.overlays.forVscode
    ];
  };

  flake.modules.homeManager."programs/vscode" = { lib, pkgs, config, ... }:
    let
      inherit (config.catppuccin) flavor;
    in
    {
      programs.vscode = {
        enable = true;
        package = pkgs.vscode-insiders;
        mutableExtensionsDir = false;

        profiles.default = {
          enableExtensionUpdateCheck = false;

          extensions = with pkgs.vscode-marketplace; [
            # Core
            github.copilot
            github.copilot-chat
            ms-vscode.remote-explorer
            ms-vscode.remote-server
            ms-vscode-remote.remote-ssh
            ms-vscode-remote.remote-ssh-edit
            ms-vscode-remote.remote-containers
            ms-vscode.remote-repositories
            # Environment
            henriquebruno.github-repository-manager
            mhutchie.git-graph
            mkhl.direnv
            # Editor
            exodiusstudios.comment-anchors
            stackbreak.comment-divider
            bierner.markdown-preview-github-styles
            bierner.markdown-checkbox
            bierner.markdown-emoji
            # Languages
            jnoortheen.nix-ide # Nix
            redhat.vscode-yaml # YAML
            tamasfe.even-better-toml # TOML
            samuelcolvin.jinjahtml # Jinja
          ];

          userSettings = {
            "update.mode" = "none";

            "workbench.colorTheme" = lib.mkForce "Catppuccin ${lib.capitalise flavor}";

            /* -------------------------------- Interface ------------------------------- */

            "window.customTitleBarVisibility" = "never";
            "window.menuBarVisibility" = "compact";
            "window.titleBarStyle" = "native";
            "window.menuStyle" = "custom";
            "window.commandCenter" = false;
            "workbench.layoutControl.enabled" = false;

            "workbench.startupEditor" = "none";
            "editor.minimap.enabled" = false;

            "explorer.compactFolders" = false;

            /* --------------------------------- Editor --------------------------------- */

            "files.autoSave" = "afterDelay";

            "direnv.restart.automatic" = true;

            "editor.acceptSuggestionOnEnter" = "off";
            "github.copilot.editor.enableAutoCompletions" = true;

            "diffEditor.ignoreTrimWhitespace" = false;

            /* ----------------------------------- Git ---------------------------------- */

            "git.defaultCloneDirectory" = config.xdg.userDirs.extraConfig.XDG_REPO_DIR or "";
            "githubRepositoryManager.alwaysCloneToDefaultDirectory" = true;

            "git.autofetch" = true;
            "git.enableSmartCommit" = true;
            "git.confirmSync" = false;
            "git.allowForcePush" = true;
            "git.replaceTagsWhenPull" = true;
            "git.ignoreRebaseWarning" = true;

            "git-graph.showStatusBarItem" = false;

            /* ----------------------------------- Nix ---------------------------------- */

            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nixd";
            "nix.formatterPath" = [ "nix" "fmt" "--" "-" ];
            "nix.serverSettings" = {
              "nil" = {
                "diagnostics" = {
                  "ignored" = [ "unused_binding" "unused_with" ];
                };
              };
            };
          };
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

      catppuccin.vscode.profiles.default = {
        enable = true;
        settings = {
          boldKeywords = true;
          italicComments = true;
          italicKeywords = true;
          colorOverrides = { };
          customUIColors = { };
          workbenchMode = "default";
          bracketMode = "rainbow";
          extraBordersEnabled = false;
        };
      };
    };
}
