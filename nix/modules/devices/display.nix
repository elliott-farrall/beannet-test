{ ... }:

{
  flake.modules.nixos."default" = { lib, config, ... }:
    let
      cfg = config.devices.display;
      inherit (cfg) width height scale;
    in
    {
      options = {
        devices.display = {
          enable = lib.mkEnableOption "display configuration";
          output = lib.mkOption {
            description = "Output of the display.";
            type = lib.types.str;
            default = "eDP-1";
          };
          width = lib.mkOption {
            description = "Width of the display.";
            type = lib.types.int;
            default = 1920;
          };
          height = lib.mkOption {
            description = "Height of the display.";
            type = lib.types.int;
            default = 1080;
          };
          refresh = lib.mkOption {
            description = "Refresh rate of the display.";
            type = lib.types.int;
            default = 60;
          };
          scale = lib.mkOption {
            description = "Scale of the display.";
            type = lib.types.float;
            default = 1.0;
          };
        };
      };

      config = lib.mkIf cfg.enable {
        # Grub
        boot.loader.grub.gfxmodeEfi = lib.mkIf config.boot.loader.grub.enable "${toString width}x${toString height}";
        # Plymouth
        boot.plymouth.extraConfig = lib.mkIf config.boot.plymouth.enable "DeviceScale=${toString (builtins.ceil scale)}";
      };
    };

  flake.modules.homeManager."default" = { lib, config, nixosConfig, ... }:
    let
      cfg = nixosConfig.devices.display;
      inherit (cfg) output width height refresh scale;
    in
    {
      config = lib.mkIf cfg.enable {
        wayland.windowManager.hyprland.settings.monitor = lib.mkIf config.wayland.windowManager.hyprland.enable [
          "${output}, ${toString width}x${toString height}@${toString refresh}, auto, ${toString scale}"
          ", preferred, auto, auto"
        ];
      };
    };
}
