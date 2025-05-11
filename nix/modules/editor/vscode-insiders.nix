{ inputs, ... }:

{
  flake.modules.nixos."default" = { ... }: {
    nixpkgs.overlays = with inputs; [ code-insiders.overlays.default ];
  };

  flake.modules.homeManager."editor/vscode-insiders" = { lib, pkgs, config, ... }:
    let
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
        profiles.default.enableExtensionUpdateCheck = false;
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

      catppuccin.vscode = {
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
