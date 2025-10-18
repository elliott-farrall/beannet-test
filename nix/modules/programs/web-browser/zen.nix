{ inputs, ... }:

{
  flake.modules.homeManager."programs/zen" = { lib, config, ... }: {
    imports = with inputs; [ zen-browser.homeModules.beta ];

    programs.zen-browser.enable = true;

    home.sessionVariables.BROWSER = lib.getExe config.programs.zen-browser.package;

    xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "zen.desktop" [
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
      "zen" = "󰖟";
    };
  };
}
