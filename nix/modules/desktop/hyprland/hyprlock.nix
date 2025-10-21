{ ... }:

let
  layout = false;
  time = true;
  date = true;
in
{
  flake.modules.nixos."desktop/hyprland" = { ... }: {
    programs.hyprlock.enable = true;
  };

  flake.modules.homeManager."desktop/hyprland" = { lib, config, ... }:
    let
      inherit (config.lib.stylix) colors;
      inherit (config.stylix) fonts;
      accent = colors.${config.catppuccin.accentBase16};
    in
    {
      programs.hyprlock = {
        enable = true;

        settings = {
          general = {
            disable_loading_bar = true;
            hide_cursor = true;
          };

          label = [
            (lib.mkIf layout {
              text = "Layout: $LAYOUT";
              color = colors.base05;
              font_size = 25;
              font_family = fonts.serif.name;
              position = "30, -30";
              halign = "left";
              valign = "top";
            })
            (lib.mkIf time {
              text = "$TIME";
              color = colors.base05;
              font_size = 90;
              font_family = fonts.serif.name;
              position = "-30, 0";
              halign = "right";
              valign = "top";
            })
            (lib.mkIf date {
              text = "cmd[update:43200000] date +\"%A, %d %B %Y\"";
              color = colors.base05;
              font_size = 25;
              font_family = fonts.serif.name;
              position = "-30, -150";
              halign = "right";
              valign = "top";
            })
          ];

          image = [
            {
              path = "${config.home.homeDirectory}/.face";
              size = 100;
              border_color = colors.base0E;
              position = "0, 75";
              halign = "center";
              valign = "center";
            }
          ];

          input-field = {
            size = "300, 60";
            outline_thickness = 4;
            dots_size = 0.2;
            dots_spacing = 0.2;
            dots_center = true;
            fade_on_empty = false;
            placeholder_text = "<span foreground=\"##${colors.base05}\"><i>󰌾 Logged in as </i><span foreground=\"##${accent}\">$USER</span></span>";
            hide_input = false;
            check_color = lib.mkForce "rgb(${accent})";
            fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
            capslock_color = colors.yellow;
            position = "0, -47";
            halign = "center";
            valign = "center";
          };
        };
      };

      catppuccin.hyprlock.useDefaultConfig = false;
      stylix.targets.hyprlock.useWallpaper = false;
    };
}
