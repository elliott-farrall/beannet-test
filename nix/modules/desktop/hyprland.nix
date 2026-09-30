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
      inherit (config.catppuccin) accent;
      accent' = colors.${lib.accentToBase16 accent};

      mkBind = key: action: opts: { _args = [ key (lib.generators.mkLuaInline action) ] ++ lib.optional (opts != { }) opts; };
      mkBind' = key: action: mkBind key action { };
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
          configType = "lua";

          settings = {
            config = {
              xwayland.force_zero_scaling = true;

              dwindle = {
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

              ecosystem = {
                no_update_news = true;
                no_donation_nag = true;
              };

              misc = {
                disable_hyprland_logo = true;
                allow_session_lock_restore = true;
              };
            };

            env = [
              { _args = [ "NIXOS_OZONE_WL" "1" ]; }
              { _args = [ "ELECTRON_OZONE_PLATFORM_HINT" "auto" ]; }
            ];

            gesture = [{
              fingers = 3;
              direction = "horizontal";
              action = "workspace";
            }];

            window_rule = [{
              match = { xwayland = 1; };
              border_color = "rgb(${colors.base0A})";
            }];

            bind = [
              (mkBind' "SUPER + ESCAPE" "hl.dsp.exit()")
              (mkBind' "SUPER + X" "hl.dsp.window.kill()")
              (mkBind' "SUPER + F" "hl.dsp.window.float({ action = \"toggle\" })")

              (mkBind' "SUPER + D" "hl.dsp.focus({ workspace = \"e+1\" })")
              (mkBind' "SUPER + A" "hl.dsp.focus({ workspace = \"e-1\" })")
              (mkBind' "SUPER + C" "hl.dsp.workspace.toggle_special(\"terminal\")")

              (mkBind' "SUPER + SHIFT + D" "hl.dsp.window.move({ workspace = \"e+1\" })")
              (mkBind' "SUPER + SHIFT + A" "hl.dsp.window.move({ workspace = \"e-1\" })")

              (mkBind' "XF86AudioMute" "hl.dsp.exec_cmd(\"${pkgs.swayosd}/bin/swayosd-client --output-volume mute-toggle\")")
              (mkBind' "XF86AudioLowerVolume" "hl.dsp.exec_cmd(\"${pkgs.swayosd}/bin/swayosd-client --output-volume lower\")")
              (mkBind' "XF86AudioRaiseVolume" "hl.dsp.exec_cmd(\"${pkgs.swayosd}/bin/swayosd-client --output-volume raise\")")
              (mkBind' "XF86AudioPrev" "hl.dsp.exec_cmd(\"${pkgs.playerctl}/bin/playerctl previous\")")
              (mkBind' "XF86AudioPlay" "hl.dsp.exec_cmd(\"${pkgs.playerctl}/bin/playerctl play-pause\")")
              (mkBind' "XF86AudioNext" "hl.dsp.exec_cmd(\"${pkgs.playerctl}/bin/playerctl next\")")
              (mkBind' "XF86MonBrightnessDown" "hl.dsp.exec_cmd(\"${pkgs.swayosd}/bin/swayosd-client --brightness lower\")")
              (mkBind' "XF86MonBrightnessUp" "hl.dsp.exec_cmd(\"${pkgs.swayosd}/bin/swayosd-client --brightness raise\")")

              (mkBind' "SUPER + PRINT" "hl.dsp.exec_cmd(\"${pkgs.hyprshot}/bin/hyprshot -m window\")")

              (mkBind "SUPER + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
              (mkBind "SUPER + mouse:273" "hl.dsp.window.resize()" { mouse = true; })

              (mkBind "SUPER + SUPER_L" "hl.dsp.exec_cmd(\"${config.programs.rofi.finalPackage}/bin/rofi -show drun\")" { release = true; })
              (mkBind "Caps_Lock" "hl.dsp.exec_cmd(\"${pkgs.swayosd}/bin/swayosd-client --caps-lock\")" { release = true; })
              (mkBind "Scroll_Lock" "hl.dsp.exec_cmd(\"${pkgs.swayosd}/bin/swayosd-client --scroll-lock\")" { release = true; })
              (mkBind "Num_Lock" "hl.dsp.exec_cmd(\"${pkgs.swayosd}/bin/swayosd-client --num-lock\")" { release = true; })
            ];
          };
        };

        /* -------------------------------- Hyprlock -------------------------------- */

        programs.hyprlock.enable = true;

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
