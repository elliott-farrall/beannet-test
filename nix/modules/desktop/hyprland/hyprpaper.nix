{ ... }:

{
  flake.modules.homeManager."desktop/hyprland" = { ... }: {
    services.hyprpaper.enable = true;
  };
}
