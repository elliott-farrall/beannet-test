{ ... }:

{
  flake.modules.homeManager."web-browser/firefox" = { lib, config, ... }: {
    programs.firefox.enable = true;

    home.sessionVariables.BROWSER = lib.getExe config.programs.firefox.package;

    xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "firefox.desktop" [
      "text/html"
      "application/pdf"
      "x-scheme-handler/about"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/unknown"
      "image/jpeg"
      "image/png"
      "image/svg"
      "image/gif"
      "image/webp"
      "image/mp4"
      "image/mpeg"
      "image/webm"
    ];

    programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
      "firefox" = "󰈹";
    };
  };
}
