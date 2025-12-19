{ ... }:

{
  flake.modules.homeManager.default = { lib, config, ... }: {
    options = {
      desktop.components.swaync.enable = lib.mkEnableOption "the swaync desktop component";
    };

    config = lib.mkIf config.desktop.components.swaync.enable {
      services.swaync = {
        enable = true;

        settings = {
          notification-2fa-action = true;
          notification-inline-replies = true;

          timeout = 10;
          timeout-low = 5;
          timeout-critical = 0;

          fit-to-screen = false;

          keyboard-shortcuts = true;

          hide-on-clear = false;
          hide-on-action = true;

          widgets = [
            "inhibitors"
            "title"
            "notifications"
            "dnd"
          ];
          widget-config = {
            inhibitors = {
              text = "Inhibitors";
              button-text = "Clear All";
              clear-all-button = true;
            };
            title = {
              text = "Notifications";
              button-text = "Clear All";
              clear-all-button = true;
            };
            dnd = {
              text = "Do Not Disturb";
            };
            mpris = {
              image-size = 96;
              image-radius = 12;
            };
            buttons-grid = {
              actions = [
                {
                  label = "󰤨";
                  type = "toggle";
                  active = true;
                  command = "sh -c '[[ $SWAYNC_TOGGLE_STATE == true ]] && nmcli radio wifi on || nmcli radio wifi off'";
                  update_command = "sh -c '[[ $(nmcli radio wifi) == \enabled\ ]] && echo true || echo false'";
                }
              ];
            };
          };
        };
      };

      catppuccin.swaync.enable = false;
    };
  };
}
