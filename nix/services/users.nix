{ config, ... }:


let
  inherit (config.flake) modules;
in
{
  flake.clan.inventory.instances."elliott" = {
    module = {
      name = "users";
      input = "clan-core";
    };

    roles.default = {
      tags."laptop" = { };
      tags."wsl" = { };

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

      extraModules = [
        { profiles.elliott.enable = true; }
      ];
    };
  };

  flake.modules.nixos.default = { lib, config, ... }: {
    imports = with modules.nixos; [ users-elliott ];

    options = {
      profiles.elliott = {
        enable = lib.mkEnableOption "the Elliott user profile";
        gui = lib.mkEnableOption "GUI features" // { default = !config.wsl.enable; };
      };
    };
  };

  flake.modules.nixos.users-elliott = { lib, config, ... }:
    let
      cfg = config.profiles.elliott;
    in
    {
      config = lib.mkIf cfg.enable {
        greeter.tuigreet.enable = true;

        desktop.environments.hyprland.enable = lib.mkIf cfg.gui true;

        applications.nemo.enable = lib.mkIf cfg.gui true;
        # applications.vscode.enable = lib.mkIf cfg.gui true;

        wsl.defaultUser = "elliott";
        home-manager.users.elliott.imports = with modules.homeManager; [ users-elliott ];
      };
    };

  flake.modules.homeManager.users-elliott = { lib, config, nixosConfig, ... }:
    let
      cfg = nixosConfig.profiles.elliott;
    in
    {
      config = lib.mkIf cfg.gui {
        desktop.environments.hyprland.enable = true;

        applications.nemo.enable = true;
        applications.vscode.enable = true;
        applications.zen.enable = true;
        applications.kitty.enable = true;

        wayland.windowManager.hyprland.settings = {
          exec-once = [
            "[workspace 1 silent] ${config.home.sessionVariables.VISUAL or ""}"
            "[workspace 2 silent] ${config.home.sessionVariables.BROWSER or ""}"
            "[workspace special:terminal silent] ${config.home.sessionVariables.TERMINAL or ""}"
          ];
        };
      };
    };
}
