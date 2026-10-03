{ inputs, ... }:

{
  flake.modules.homeManager.default = { lib, pkgs, config, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      zenPackage = inputs.zen-browser.packages.${system}.default or (throw "Zen Browser is not supported on ${system}");
    in
    {
      imports = with inputs; [ zen-browser.homeModules.default ];

      options = {
        applications.zen.enable = lib.mkEnableOption "the Zen application";
      };

      config = lib.mkIf config.applications.zen.enable {
        programs.zen-browser = {
          enable = true;
          package = zenPackage;
          profiles.default = { };
        };

        home.sessionVariables.BROWSER = lib.getExe config.programs.zen-browser.package;

        xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "zen-beta.desktop" (lib.importJSON ./desktop/associations.json).browser;

        desktop.wmIcons."zen" = "󰖟";

        stylix.targets.zen-browser.profileNames = [ "default" ];

        home.persistence.state.directories = [ ".config/zen" ];
      };
    };
}
