{ ... }:

{
  flake.modules.nixos."desktop/hyprland" = { ... }: {
    programs.hyprland.enable = true;
  };

  flake.modules.homeManager."desktop/hyprland" = { lib, pkgs, config, ... }:
    let
      inherit (config.lib.stylix) colors;
      accent = colors.${config.catppuccin.accentBase16};
    in
    {
      wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;

        settings = {
          xwayland.force_zero_scaling = true;
          windowrulev2 = [
            "bordercolor rgb(${colors.base0A}), xwayland:1"
          ];

          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };

          general = {
            gaps_in = 10;
            gaps_out = 10;
            resize_on_border = true;
            "col.active_border" = lib.mkForce "rgb(${accent})";
          };
          decoration = {
            rounding = 10;
            active_opacity = config.stylix.opacity.applications;
            inactive_opacity = config.stylix.opacity.applications;
            fullscreen_opacity = config.stylix.opacity.applications;
          };
          group = {
            "col.border_active" = lib.mkForce "rgb(${accent})";

            groupbar = {
              "col.active" = lib.mkForce "rgb(${accent})";
            };
          };

          input = {
            kb_layout = "gb";
            touchpad.natural_scroll = true;
          };

          bindr = [
            "SUPER, SUPER_L, exec, pkill rofi || ${config.programs.rofi.finalPackage}/bin/rofi -show drun"

            "Caps_Lock, Caps_Lock, exec, ${pkgs.swayosd}/bin/swayosd-client --caps-lock"
            ", Scroll_Lock, exec, ${pkgs.swayosd}/bin/swayosd-client --scroll-lock"
            ", Num_Lock, exec, ${pkgs.swayosd}/bin/swayosd-client --num-lock"
          ];
          bind = [
            "SUPER, ESCAPE, exit,"
            "SUPER, X, killactive,"
            "SUPER, F, togglefloating, c"

            "SUPER, D, workspace, +1"
            "SUPER, A, workspace, -1"
            "SUPER, C, togglespecialworkspace, terminal"

            "SUPER SHIFT, D, movetoworkspace, +1"
            "SUPER SHIFT, A, movetoworkspace, -1"

            ", XF86AudioMute, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume mute-toggle"
            ", XF86AudioLowerVolume, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume lower"
            ", XF86AudioRaiseVolume, exec, ${pkgs.swayosd}/bin/swayosd-client --output-volume raise"
            ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
            ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
            ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
            ", XF86MonBrightnessDown, exec, ${pkgs.swayosd}/bin/swayosd-client --brightness lower"
            ", XF86MonBrightnessUp, exec, ${pkgs.swayosd}/bin/swayosd-client --brightness raise"
            # Super_L+p         -> Presentation mode
            # XF86RFKill        -> Airplane mode
            # Print             -> Screenshot
            # XF86AudioMedia    -> Settings?

            "SUPER, PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot -m window"
          ];
          bindm = [
            "SUPER, mouse:272, movewindow"
            "SUPER, mouse:273, resizewindow"
          ];

          misc = {
            disable_hyprland_logo = true;
            allow_session_lock_restore = true;
          };
        };
      };
    };
}
