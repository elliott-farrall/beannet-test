{ ... }:

{
  flake.modules.homeManager.default = { lib, config, ... }: {
    options = {
      applications.obsidian.enable = lib.mkEnableOption "the Obsidian application";
    };

    config = lib.mkIf config.applications.obsidian.enable {
      programs.obsidian.enable = true;

      xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "obsidian.desktop" (lib.readYAML ./desktop/associations.yaml).notes;

      desktop.wmIcons."obsidian" = "";
    };
  };
}
