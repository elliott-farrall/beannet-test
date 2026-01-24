{ ... }:

{
  flake.modules.nixos.default = { lib, pkgs, config, ... }: {
    config = lib.mkIf config.desktop.environments.hyprland.enable {
      services.greetd = {
        enable = true;

        settings.default_session.command = "${lib.getExe pkgs.hyprland} &> /dev/null";
      };
    };
  };

  flake.modules.homeManager.default = { lib, pkgs, config, ... }: {
    config = lib.mkIf config.desktop.environments.hyprland.enable {
      wayland.windowManager.hyprland.settings.exec-once = [ (lib.getExe pkgs.hyprlock) ];
    };
  };
}
