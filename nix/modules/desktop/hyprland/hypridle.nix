{ ... }:

{
  flake.modules.nixos."desktop/hyprland" = { ... }: {
    services.hypridle.enable = true;
  };

  flake.modules.homeManager."desktop/hyprland" = { pkgs, ... }: {
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
  };
}
