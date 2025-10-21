{ config, ... }:

{
  flake.modules.homeManager."desktop/hyprland" = { ... }: {
    imports = with config.flake.modules; [
      homeManager."desktop/components/rofi"
      homeManager."desktop/components/swaync"
      homeManager."desktop/components/swayosd"
      homeManager."desktop/components/waybar"
      homeManager."desktop/components/wlogout"
    ];
  };
}
