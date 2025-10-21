{ ... }:

{
  flake.modules.homeManager."default" = { lib, config, ... }:
    let
      inherit (config.lib.stylix) colors;
      accent = colors.${config.catppuccin.accentBase16};
    in
    {
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

          style = lib.mkAfter /*css*/''
            /* Colours */

            @define-color accent #${accent};

            @define-color base @base00;
            @define-color crust @base01;
            @define-color surface0 @base02;
            @define-color surface1 @base03;
            @define-color surface2 @base04;
            @define-color text @base05;

            @define-color red @base08;
            @define-color peach @base09;
            @define-color yellow @base0A;
            @define-color teal @base0C;
            @define-color blue @base0D;

            /* Overrides */

            .notification.low,
            .notification.normal,
            .notification.critical {
              border: none;
            }

            .notification-content {
              background: @mantle;
              border: none;
            }

            .control-center {
              border: none;
            }

            .widget-title > button {
              border: none;
            }

            /* Theme */

            * {
              all: unset;
              transition: 200ms;
            }

            trough highlight {
              background: @text;
            }

            scale trough {
              margin: 0rem 1rem;
              background-color: @surface0;
              min-height: 8px;
              min-width: 70px;
            }

            slider {
              background-color: @blue;
            }

            .floating-notifications.background .notification-row .notification-background {
              box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px @surface0;
              border-radius: 12.6px;
              margin: 18px;
              background-color: @base;
              color: @text;
              padding: 0;
            }

            .floating-notifications.background .notification-row .notification-background .notification {
              padding: 7px;
              border-radius: 12.6px;
            }

            .floating-notifications.background .notification-row .notification-background .notification.critical {
              box-shadow: inset 0 0 7px 0 @red;
            }

            .floating-notifications.background .notification-row .notification-background .notification .notification-content {
              margin: 7px;
            }

            .floating-notifications.background .notification-row .notification-background .notification .notification-content .summary {
              color: @text;
            }

            .floating-notifications.background .notification-row .notification-background .notification .notification-content .time {
              color: @text;
            }

            .floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
              color: @text;
            }

            .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
              min-height: 3.4em;
            }

            .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
              border-radius: 7px;
              color: @text;
              background-color: @surface0;
              box-shadow: inset 0 0 0 1px @surface1;
              margin: 7px;
            }

            .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
              box-shadow: inset 0 0 0 1px @surface1;
              background-color: @surface0;
              color: @text;
            }

            .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
              box-shadow: inset 0 0 0 1px @surface1;
              background-color: @blue;
              color: @text;
            }

            .floating-notifications.background .notification-row .notification-background .close-button {
              margin: 7px;
              padding: 2px;
              border-radius: 6.3px;
              color: @base;
              background-color: @red;
            }

            .floating-notifications.background .notification-row .notification-background .close-button:hover {
              background-color: @red;
              color: @base;
            }

            .floating-notifications.background .notification-row .notification-background .close-button:active {
              background-color: @red;
              color: @base;
            }

            .control-center {
              box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px @surface0;
              border-radius: 12.6px;
              margin: 18px;
              background-color: @base;
              color: @text;
              padding: 14px;
            }

            .control-center .widget-title > label {
              color: @text;
              font-size: 1.3em;
            }

            .control-center .widget-title button {
              border-radius: 7px;
              color: @text;
              background-color: @surface0;
              box-shadow: inset 0 0 0 1px @surface1;
              padding: 8px;
            }

            .control-center .widget-title button:hover {
              box-shadow: inset 0 0 0 1px @surface1;
              background-color: @surface2;
              color: @text;
            }

            .control-center .widget-title button:active {
              box-shadow: inset 0 0 0 1px @surface1;
              background-color: @blue;
              color: @base;
            }

            .control-center .notification-row .notification-background {
              border-radius: 7px;
              color: @text;
              background-color: @surface0;
              box-shadow: inset 0 0 0 1px @surface1;
              margin-top: 14px;
            }

            .control-center .notification-row .notification-background .notification {
              padding: 7px;
              border-radius: 7px;
            }

            .control-center .notification-row .notification-background .notification.critical {
              box-shadow: inset 0 0 7px 0 @red;
            }

            .control-center .notification-row .notification-background .notification .notification-content {
              margin: 7px;
            }

            .control-center .notification-row .notification-background .notification .notification-content .summary {
              color: @text;
            }

            .control-center .notification-row .notification-background .notification .notification-content .time {
              color: @text;
            }

            .control-center .notification-row .notification-background .notification .notification-content .body {
              color: @text;
            }

            .control-center .notification-row .notification-background .notification > *:last-child > * {
              min-height: 3.4em;
            }

            .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
              border-radius: 7px;
              color: @text;
              background-color: @crust;
              box-shadow: inset 0 0 0 1px @surface1;
              margin: 7px;
            }

            .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
              box-shadow: inset 0 0 0 1px @surface1;
              background-color: @surface0;
              color: @text;
            }

            .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
              box-shadow: inset 0 0 0 1px @surface1;
              background-color: @blue;
              color: @text;
            }

            .control-center .notification-row .notification-background .close-button {
              margin: 7px;
              padding: 2px;
              border-radius: 6.3px;
              color: @base;
              background-color: @red;
            }

            .close-button {
              border-radius: 6.3px;
            }

            .control-center .notification-row .notification-background .close-button:hover {
              background-color: @red;
              color: @base;
            }

            .control-center .notification-row .notification-background .close-button:active {
              background-color: @red;
              color: @base;
            }

            .control-center .notification-row .notification-background:hover {
              box-shadow: inset 0 0 0 1px @surface1;
              background-color: @surface2;
              color: @text;
            }

            .control-center .notification-row .notification-background:active {
              box-shadow: inset 0 0 0 1px @surface1;
              background-color: @blue;
              color: @text;
            }

            .notification.critical progress {
              background-color: @red;
            }

            .notification.low progress,
            .notification.normal progress {
              background-color: @blue;
            }

            .control-center-dnd {
              margin-top: 5px;
              border-radius: 8px;
              background: @surface0;
              border: 1px solid @surface1;
              box-shadow: none;
            }

            .control-center-dnd:checked {
              background: @surface0;
            }

            .control-center-dnd slider {
              background: @surface1;
              border-radius: 8px;
            }

            .widget-dnd {
              margin: 0px;
              font-size: 1.1rem;
            }

            .widget-dnd > switch {
              font-size: initial;
              border-radius: 8px;
              background: @surface0;
              border: 1px solid @surface1;
              box-shadow: none;
            }

            .widget-dnd > switch:checked {
              background: @surface0;
            }

            .widget-dnd > switch slider {
              background: @surface1;
              border-radius: 8px;
              border: 1px solid @surface2;
            }

            .widget-mpris .widget-mpris-player {
              background: @surface0;
              padding: 7px;
            }

            .widget-mpris .widget-mpris-title {
              font-size: 1.2rem;
            }

            .widget-mpris .widget-mpris-subtitle {
              font-size: 0.8rem;
            }

            .widget-menubar > box > .menu-button-bar > button > label {
              font-size: 3rem;
              padding: 0.5rem 2rem;
            }

            .widget-menubar > box > .menu-button-bar > :last-child {
              color: @red;
            }

            .power-buttons button:hover,
            .powermode-buttons button:hover,
            .screenshot-buttons button:hover {
              background: @surface0;
            }

            .control-center .widget-label > label {
              color: @text;
              font-size: 2rem;
            }

            .widget-buttons-grid {
              padding-top: 1rem;
            }

            .widget-buttons-grid > flowbox > flowboxchild > button label {
              font-size: 2.5rem;
            }

            .widget-volume {
              padding-top: 1rem;
            }

            .widget-volume label {
              font-size: 1.5rem;
              color: @blue;
            }

            .widget-volume trough highlight {
              background: @blue;
            }

            .widget-backlight trough highlight {
              background: @yellow;
            }

            .widget-backlight label {
              font-size: 1.5rem;
              color: @yellow;
            }

            .widget-backlight .KB {
              padding-bottom: 1rem;
            }

            .image {
              padding-right: 0.5rem;
            }
          '';
        };

        catppuccin.swaync.enable = false;
      };
    };
}
