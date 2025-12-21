{ inputs, ... }:

{
  flake.modules.homeManager.default = { lib, config, ... }: {
    imports = with inputs; [ zen-browser.homeModules.default ];

    options = {
      applications.zen.enable = lib.mkEnableOption "the Zen application";
    };

    config = lib.mkIf config.applications.zen.enable {
      programs.zen-browser.enable = true;

      home.sessionVariables.BROWSER = lib.getExe config.programs.zen-browser.package;

      xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "zen-beta.desktop" (lib.readYAML ./desktop/associations.yaml).browser;

      desktop.wmIcons."zen" = "󰖟";

      stylix.targets.zen-browser.profileNames = [ "default" ];

      home.persistence.state.directories = [ ".zen" ];
    };
  };
}
