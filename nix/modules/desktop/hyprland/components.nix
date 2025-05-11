{ config, ... }:

{
  flake.modules.homeManager."desktop/hyprland" = { ... }: {
    imports = with config.flake.modules; [
      homeManager."components/rofi"
      homeManager."components/swaync"
      homeManager."components/swayosd"
      homeManager."components/waybar"
      homeManager."components/wlogout"
    ];
  };
}
