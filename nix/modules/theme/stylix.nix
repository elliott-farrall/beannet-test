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

        image = "${inputs.wallpapers}/os/nix-black-4k.png";

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
      };
    };

  flake.modules.homeManager.default = { pkgs, config, ... }: {
    stylix = {
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

      # FIXME - https://github.com/nix-community/stylix/issues/1560#issuecomment-3663030523
      targets.gnome.enable = false;
      targets.gtk.extraCss = ''
        .dialog-action-area > .text-button {
          color: @dialog_fg_color;
        }
      '';
    };
  };
}
