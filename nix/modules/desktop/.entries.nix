{ ... }:

{
  flake.modules.homeManager.default = { lib, config, ... }:
    let
      entryDirectory = "${config.home.homeDirectory}/.local/state/nix/profile/share/applications";
    in
    {
      # Prioritise declarative entries for desktop environments
      xdg.dataFile.applications.source = config.lib.file.mkOutOfStoreSymlink entryDirectory;

      # Hide unwanted entries
      xdg.desktopEntries = lib.genAttrs [
        "cups"
        "discord"
        "htop"
        "kitty"
        "kvantummanager"
        "qt5ct"
        "qt6ct"
        "remote-viewer"
        "rofi"
        "rofi-theme-selector"
      ]
        (name: { inherit name; noDisplay = true; });
    };
}
