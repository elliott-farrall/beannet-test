{ ... }:

{
  flake.modules.nixos.default = { lib, config, ... }: {
    options = {
      desktop.environments.hyprland.enable = lib.mkEnableOption "the Hyprland desktop environment";
    };

    config = lib.mkIf config.desktop.environments.hyprland.enable {
      services.gnome.gnome-keyring.enable = true;

      programs.hyprland.enable = true;

      programs.hyprlock.enable = true;

      services.hypridle.enable = true;
    };
  };

  flake.modules.homeManager.default = { lib, pkgs, config, nixosConfig, ... }:
    let
      inherit (config.lib.stylix) colors;
      inherit (config.stylix) fonts;
      inherit (config.catppuccin) accent;
      accent' = colors.${lib.accentToBase16 accent};

      layout = false;
      time = true;
      date = true;
    in
    {
      options = {
        desktop.environments.hyprland.enable = lib.mkEnableOption "the Hyprland desktop environment";
      };

      config = lib.mkIf config.desktop.environments.hyprland.enable {
        desktop.components = {
          rofi.enable = true;
          swaync.enable = true;
          swayosd.enable = true;
          waybar.enable = true;
          wlogout.enable = true;
        };

        /* ------------------------------- Environment ------------------------------ */

        assertions = [
          {
            assertion = nixosConfig.services.pipewire.enable;
            message = "Hyprland requires PipeWire to be enabled for screensharing";
          }
          {
            assertion = nixosConfig.services.pipewire.wireplumber.enable;
            message = "Hyprland requires WirePlumber to be enabled for screensharing";
          }
        ];

        wayland.windowManager.hyprland.extraConfig = ''
          env = NIXOS_OZONE_WL, 1
          env = ELECTRON_OZONE_PLATFORM_HINT, auto
        '';

        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [ xdg-desktop-portal-hyprland xdg-desktop-portal-gtk ];
          configPackages = with pkgs; [ hyprland ];
        };

        services.gnome-keyring.enable = true;
        home.persistence.state.directories = [ ".local/share/keyrings" ];

        /* -------------------------------- Hyprland -------------------------------- */

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
              "col.active_border" = lib.mkForce "rgb(${accent'})";
            };
            decoration = {
              rounding = 10;
              active_opacity = config.stylix.opacity.applications;
              inactive_opacity = config.stylix.opacity.applications;
              fullscreen_opacity = config.stylix.opacity.applications;
            };
            group = {
              "col.border_active" = lib.mkForce "rgb(${accent'})";

              groupbar = {
                "col.active" = lib.mkForce "rgb(${accent'})";
              };
            };

            input = {
              kb_layout = "gb";
              touchpad.natural_scroll = true;
            };

            gesture = [
              "3, horizontal, workspace"
            ];
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

            ecosystem = {
              no_update_news = true;
              no_donation_nag = true;
            };

            misc = {
              disable_hyprland_logo = true;
              allow_session_lock_restore = true;
            };
          };
        };

        /* -------------------------------- Hyprlock -------------------------------- */

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
              placeholder_text = "<span foreground=\"##${colors.base05}\"><i>󰌾 Logged in as </i><span foreground=\"##${accent'}\">$USER</span></span>";
              hide_input = false;
              check_color = lib.mkForce "rgb(${accent'})";
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

        /* -------------------------------- Hypridle -------------------------------- */

        services.hypridle = {
          enable = true;

          settings = {
            general = {
              lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
              before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
              after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
            };

            listener = [
              {
                # dim screen
                timeout = 150;
                on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
                on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
              }
              {
                # dim keyboard
                timeout = 150;
                on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -sd rgb:kbd_backlight set 0";
                on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -rd rgb:kbd_backlight";
              }
              {
                # lock screen
                timeout = 300;
                on-timeout = "${pkgs.systemd}/bin/loginctl lock-session";
              }
              {
                # disable screen
                timeout = 330;
                on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
                on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on && ${pkgs.brightnessctl}/bin/brightnessctl -r";
              }
              {
                # suspend
                timeout = 1800;
                on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
              }
            ];
          };
        };

        /* -------------------------------- Hyprpaper ------------------------------- */

        services.hyprpaper.enable = true;
      };
    };
}
