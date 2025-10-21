{ ... }:

{
  flake.modules.homeManager."programs/obsidian" = { lib, ... }: {
    programs.obsidian.enable = true;

    xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "obsidian.desktop" builtins.fromJSON.associations.json.notes;

    desktop.wmIcons."obsidian" = "";
  };
}
