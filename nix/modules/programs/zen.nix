{ inputs, ... }:

{
  flake.modules.homeManager."programs/zen" = { lib, config, ... }: {
    imports = with inputs; [ zen-browser.homeModules.default ];

    programs.zen-browser.enable = true;

    home.sessionVariables.BROWSER = lib.getExe config.programs.zen-browser.package;

    xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "zen.desktop" builtins.fromJSON.associations.json.web;

    desktop.wmIcons."zen" = "󰖟";

    stylix.targets.zen-browser.profileNames = [ "default" ];

    home.persistence.state.directories = [ ".zen" ];
  };
}
