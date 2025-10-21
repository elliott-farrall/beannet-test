{ ... }:

{
  flake.modules.homeManager."default" = { lib, config, ... }: {
    options = {
      applications.obsidian.enable = lib.mkEnableOption "the Obsidian application";
    };

    config = lib.mkIf config.applications.obsidian.enable {
      programs.obsidian.enable = true;

      xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "obsidian.desktop" builtins.fromJSON.associations.json.notes;

      desktop.wmIcons."obsidian" = "";
    };
  };
}
