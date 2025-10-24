{ inputs, ... }:

{
  flake.modules.nixos.default = { lib, pkgs, config, ... }:
    let
      inherit (config.catppuccin) flavor accent;
    in
    {
      imports = with inputs; [ stylix.nixosModules.stylix ];

      stylix = {
        enable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-${flavor}.yaml";
        image = pkgs.fetchurl {
          url = "https://images.pexels.com/photos/1146134/pexels-photo-1146134.jpeg?cs=srgb&dl=pexels-umkreisel-app-1146134.jpg&fm=jpg&_gl=1*mfkk8u*_ga*MTM5OTI0MTA4Ni4xNzUyMjYzNjYx*_ga_8JE65Q40S6*czE3NTIyNjM2NjEkbzEkZzEkdDE3NTIyNjM2NzEkajUwJGwwJGgw";
          hash = "sha256-VPDDQkgqbOn/oOoFcdgPGwjLCaIQJBalgCH+zVG8jGA=";
        };

        polarity = if flavor == "latte" then "light" else "dark";

        cursor = {
          name = "catppuccin-${flavor}-${accent}-cursors";
          package = pkgs.catppuccin-cursors."${flavor}${lib.capitalise accent}";
          size = 24;
        };

        fonts = {
          serif = {
            name = "JetBrainsMono Nerd Font";
            package = pkgs.nerd-fonts.jetbrains-mono;
          };
          sansSerif = {
            name = "JetBrainsMono Nerd Font";
            package = pkgs.nerd-fonts.jetbrains-mono;
          };
          monospace = {
            name = "JetBrainsMono Nerd Font";
            package = pkgs.nerd-fonts.jetbrains-mono;
          };
          emoji = {
            name = "Noto Color Emoji";
            package = pkgs.noto-fonts-color-emoji;
          };
          sizes = {
            applications = 11;
            desktop = 11;
            popups = 11;
            terminal = 11;
          };
        };

        homeManagerIntegration.autoImport = false;
      };
    };

  flake.modules.homeManager.default = { pkgs, config, nixosConfig, ... }: {
    imports = with inputs; [ stylix.homeModules.stylix ];

    stylix = {
      inherit (nixosConfig.stylix) enable base16Scheme image polarity cursor;

      fonts = { inherit (nixosConfig.stylix.fonts) serif sansSerif monospace emoji sizes; };

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
