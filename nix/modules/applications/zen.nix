{ inputs, ... }:

{
  flake.modules.nixos.default = { ... }: {
    nixpkgs.overlays = [
      (final: prev: {
        zen-browser = final.callPackage
          (_args: final.symlinkJoin {
            name = inputs.zen-browser.packages.${prev.system}.default.pname;
            paths = [ inputs.zen-browser.packages.${prev.system}.default ];

            postBuild = ''
              sed -i ";" $out/share/applications/zen-beta.desktop
              substituteInPlace $out/share/applications/zen-beta.desktop \
                --replace-warn "Name=Zen Browser (Beta)" "Name=Zen"
            '';
          })
          { };
      })
    ];
  };

  flake.modules.homeManager.default = { lib, pkgs, config, ... }: {
    imports = with inputs; [ zen-browser.homeModules.default ];

    options = {
      applications.zen.enable = lib.mkEnableOption "the Zen application";
    };

    config = lib.mkIf config.applications.zen.enable {
      programs.zen-browser = {
        enable = true;
        package = pkgs.zen-browser;
      };

      home.sessionVariables.BROWSER = lib.getExe config.programs.zen-browser.package;

      xdg.mimeApps.defaultApplications = lib.mkDefaultApplications "zen-beta.desktop" (lib.readYAML ./desktop/associations.yaml).browser;

      desktop.wmIcons."zen" = "󰖟";

      stylix.targets.zen-browser.profileNames = [ "default" ];

      home.persistence.state.directories = [ ".zen" ];
    };
  };
}
