{ config, ... }:


let
  inherit (config.flake) modules;
in
{
  flake.clan.inventory.instances."elliott" = {
    module = {
      name = "users";
      input = "clan-core";
    };

    roles.default = {
      tags = [ "laptop" "wsl" ];

      settings = {
        user = "elliott";
        prompt = true;

        groups = [
          "wheel"

          "adbusers"
          "docker"
          "kvm"
          "lpadmin"
          "networkmanager"
          "openrazer"
          "podman"
        ];
      };

      extraModules = [
        { profiles.elliott.enable = true; }
      ];
    };
  };

  flake.modules.nixos.default = { lib, config, ... }: {
    imports = with modules.nixos; [ users-elliott ];

    options = {
      profiles.elliott = {
        enable = lib.mkEnableOption "the Elliott user profile";
        gui = lib.mkEnableOption "GUI features" // { default = !config.wsl.enable; };
      };
    };
  };

  flake.modules.nixos.users-elliott = { lib, config, ... }:
    let
      cfg = config.profiles.elliott;
    in
    {
      config = lib.mkIf cfg.enable {
        greeter.tuigreet.enable = true;

        desktop.environments.hyprland.enable = lib.mkIf cfg.gui true;

        applications.nemo.enable = lib.mkIf cfg.gui true;
        # applications.vscode.enable = lib.mkIf cfg.gui true;

        wsl.defaultUser = "elliott";
        home-manager.users.elliott.imports = with modules.homeManager; [ users-elliott ];
      };
    };

  flake.modules.homeManager.users-elliott = { lib, config, nixosConfig, ... }:
    let
      cfg = nixosConfig.profiles.elliott;
    in
    {
      config = lib.mkIf cfg.gui {
        desktop.environments.hyprland.enable = true;

        applications.nemo.enable = true;
        applications.vscode.enable = true;
        applications.zed.enable = true;
        applications.zen.enable = true;

        wayland.windowManager.hyprland = lib.mkIf config.wayland.windowManager.hyprland.enable {
          extraConfig =
            let
              editor = "${config.programs.vscode.package}/bin/code-insiders";
              browser = config.home.sessionVariables.BROWSER or "";
              terminal = config.home.sessionVariables.TERMINAL or "";
            in
            ''
              hl.on("hyprland.start", function()
                hl.exec_cmd("${editor}", { workspace = "1 silent" })
                ${lib.optionalString (browser != "") ''hl.exec_cmd("${browser}", { workspace = "2 silent" })''}
                ${lib.optionalString (terminal != "") ''hl.exec_cmd("${terminal}", { workspace = "special:terminal silent" })''}

                hl.dispatch(hl.dsp.focus({ workspace = "1" }))
              end)
            '';

          settings.window_rule = [
            { match = { class = "code-insiders"; }; workspace = "1"; }
            { match = { class = "zen-beta"; }; workspace = "2"; }
            { match = { class = "kitty"; }; workspace = "special:terminal"; }
          ];
        };
      };
    };
}
