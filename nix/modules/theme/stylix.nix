{ inputs, ... }:

{
  flake.modules.nixos."default" = { lib, pkgs, config, ... }:
    let
      inherit (config.catppuccin) flavor accent;
    in
    {
      imports = with inputs; [ stylix.nixosModules.stylix ];

      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${flavor}.yaml";

        polarity = if flavor == "latte" then "light" else "dark";

        cursor = {
          name = "catppuccin-${flavor}-${accent}-cursors";
          package = pkgs.catppuccin-cursors."${flavor}${lib.capitalise accent}";
          size = 24;
        };

        fonts = {
          serif = {
            name = "Ubuntu Nerd Font";
            package = pkgs.nerd-fonts.ubuntu;
          };
          sansSerif = {
            name = "Ubuntu Nerd Font";
            package = pkgs.nerd-fonts.ubuntu;
          };
          monospace = {
            name = "UbuntuMono Nerd Font";
            package = pkgs.nerd-fonts.ubuntu-mono;
          };
          emoji = {
            name = "Noto Color Emoji";
            package = pkgs.noto-fonts-color-emoji;
          };
          sizes = {
            applications = 10;
            desktop = 10;
            popups = 10;
            terminal = 11;
          };
        };

        homeManagerIntegration.autoImport = false;
      };
    };

  flake.modules.homeManager."default" = { pkgs, config, nixosConfig, ... }: {
    imports = [ inputs.stylix.homeManagerModules.stylix ];

    stylix = {
      inherit (nixosConfig.stylix) enable base16Scheme polarity cursor; # FIXME - inherit fonts in stylix config

      iconTheme = {
        enable = true;
        dark = "Papirus-Dark";
        light = "Papirus-Light";
        package = pkgs.catppuccin-papirus-folders.override { inherit (config.catppuccin) flavor accent; };
      };

      opacity = {
        applications = 0.9;
        desktop = 0.9;
        popups = 1.0;
        terminal = 0.9;
      };

      targets.gnome.enable = false;
    };
  };
}
