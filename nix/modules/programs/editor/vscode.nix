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

      # TODO - Move to overlay
      package = pkgs.vscode-insiders.overrideAttrs (attrs: {
        desktopItems = [
          ((lib.lists.findFirst (item: item.name == "code-insiders.desktop") null attrs.desktopItems).override {
            desktopName = "VS Code";
          })
          ((lib.lists.findFirst (item: item.name == "code-insiders-url-handler.desktop") null attrs.desktopItems).override {
            desktopName = "VS Code URL Handler";
          })
        ];
        postInstall =
          if config.wayland.windowManager.hyprland.enable then ''
            wrapProgram $out/bin/code-insiders \
              --set ELECTRON_OZONE_PLATFORM_HINT auto
          '' else null;
      });
    in
    {
      programs.vscode = {
        enable = true;
        inherit package;
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

      xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "code-insiders.desktop" [
        "text/plain"
        "text/html"
        "text/css"
        "text/javascript"
        "application/javascript"
        "application/json"
        "application/xml"
        "application/x-yaml"
        "application/x-python"
        "application/x-php"
        "application/x-ruby"
        "application/x-perl"
        "application/x-shellscript"
        "application/x-csrc"
        "application/x-c++src"
        "application/x-java"
        "application/sql"
      ] // {
        "application/x-desktop" = "code-insiders-url-handler.desktop";
      };

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

      programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
        "code-insiders" = "󰨞";
      };
    };
}
