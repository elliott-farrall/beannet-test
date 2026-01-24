{ config, ... }:


let
  inherit (config.flake) modules;
in
{
  flake.clan.inventory.instances."elliott-default" = {
    module = {
      name = "users";
      input = "clan-core";
    };

    roles.default = {
      tags."all" = { };

      settings = {
        user = "elliott";
        prompt = true;

        groups = [
          "wheel"

          "adbusers"
          "docker"
          "lpadmin"
          "networkmanager"
          "openrazer"
          "podman"
        ];
      };
    };
  };

  flake.clan.inventory.instances."elliott-desktop" = {
    module = {
      name = "importer";
      input = "clan-core";
    };

    roles.default = {
      tags."laptop" = { };

      extraModules = [
        { desktop.users.elliott.enable = true; }
      ];
    };
  };

  flake.modules.nixos.default = { lib, ... }: {
    imports = with modules.nixos; [ users-elliott ];

    options = {
      desktop.users.elliott.enable = lib.mkEnableOption "the desktop profile for Elliott";
    };

    config = {
      home-manager.users.elliott.imports = with modules.homeManager; [ users-elliott ];

      services.greetd.settings.default_session.user = "elliott";
      wsl.defaultUser = "elliott";

      system.activationScripts."persist-elliott".text = ''
        mkdir -p /pst/state/home/elliott
        chown elliott:users /pst/state/home/elliott

        mkdir -p /pst/data/home/elliott
        chown elliott:users /pst/data/home/elliott
      '';
    };
  };

  flake.modules.nixos.users-elliott = { lib, config, ... }:
    let
      inherit (config.desktop.users.elliott) enable;
    in
    {
      config = lib.mkIf enable {
        desktop.environments.hyprland.enable = true;

        applications.nemo.enable = true;
        applications.vscode.enable = true;
      };
    };

  flake.modules.homeManager.users-elliott = { lib, config, nixosConfig, ... }:
    let
      inherit (nixosConfig.desktop.users.elliott) enable;
    in
    {
      config = lib.mkIf enable {
        desktop.environments.hyprland.enable = true;

        applications.nemo.enable = true;
        applications.vscode.enable = true;
        applications.zen.enable = true;
        applications.kitty.enable = true;

        wayland.windowManager.hyprland.settings = with config.home; {
          exec-once = [
            "[workspace 1 silent] ${sessionVariables.VISUAL or ""}"
            "[workspace 2 silent] ${sessionVariables.BROWSER or ""}"
            "[workspace special:terminal silent] ${sessionVariables.TERMINAL or ""}"
          ];
        };
      };
    };
}
