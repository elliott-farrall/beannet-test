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

      settings = {
        user = "elliott";
        share = true;
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

  flake.modules.nixos."default" = { lib, ... }: {
    imports = with modules; [ nixos."users/elliott" ];

    options = {
      profiles.elliott.enable = lib.mkEnableOption "the Elliott user profile";
    };
  };

  flake.modules.nixos."users/elliott" = { lib, config, ... }: {
    config = lib.mkIf config.profiles.elliott.enable {
      greeter.tuigreet.enable = true;

      desktop.environments.hyprland.enable = true;

      applications.nemo.enable = true;
      applications.vscode.enable = true;

      home-manager.users.elliott.imports = with modules; [ homeManager."users/elliott" ];
    };
  };

  flake.modules.homeManager."users/elliott" = { config, ... }: {
    config = {
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
