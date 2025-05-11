{ ... }:

{
  flake.modules.homeManager."profiles/uos" = { lib, config, nixosConfig, ... }: {
    config = lib.mkIf (nixosConfig.display.enable && config.wayland.windowManager.hyprland.enable) {
      wayland.windowManager.hyprland.settings.monitor = [
        "desc:Crestron Electronics Inc. Crestron, preferred, auto, auto, mirror, ${nixosConfig.display.output}"
        "desc:Crestron Electronics Inc. Crestron 420, preferred, auto, auto, mirror, ${nixosConfig.display.output}"
        "desc: Sony SONY TV, preferred, auto, auto, mirror, ${nixosConfig.display.output}"
      ];
    };
  };
}
