{ ... }:

{
  flake.modules.homeManager."programs/discord" = { lib, pkgs, config, ... }: {
    home.packages = [
      # TODO - Move to overlay

      # discord
      (pkgs.discord.overrideAttrs (attrs: {
        desktopItem = attrs.desktopItem.override {
          noDisplay = true;
        };
      }))
      # vesktop
      (pkgs.vesktop.overrideAttrs (attrs: {
        desktopItems = [
          ((lib.lists.findFirst (_: true) null attrs.desktopItems).override {
            desktopName = "Discord";
            icon = "discord";
          })
        ];
      }))
    ];

    programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
      "discord" = "󰙯";
    };
  };
}
