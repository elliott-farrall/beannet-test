{ inputs, ... }:

let
  accentToBase16 = {
    red = "red";
    peach = "orange";
    yellow = "yellow";
    green = "green";
    teal = "cyan";
    blue = "blue";
    mauve = "magenta";
    flamingo = "brown";
  };
in
{
  flake.modules.nixos."default" = { lib, config, ... }: {
    imports = with inputs; [ catppuccin.nixosModules.catppuccin ];

    options.catppuccin = {
      accentBase16 = lib.mkOption {
        description = "The Base16 compliant name for the accent color.";
        type = lib.types.enum (lib.attrValues accentToBase16);
        default = accentToBase16.${config.catppuccin.accent};
        internal = true;
      };
    };

    config.catppuccin = {
      enable = true;
      flavor = "macchiato";
      accent = "mauve";
    };
  };

  flake.modules.homeManager."default" = { lib, config, nixosConfig, ... }: {
    imports = with inputs; [ catppuccin.homeModules.catppuccin ];

    options.catppuccin = {
      accentBase16 = lib.mkOption {
        description = "The Base16 compliant name for the accent color.";
        type = lib.types.enum (lib.attrValues accentToBase16);
        default = accentToBase16.${config.catppuccin.accent};
        internal = true;
      };
    };

    config.catppuccin = {
      inherit (nixosConfig.catppuccin) enable flavor accent accentBase16;
      gtk.icon.enable = false;
      kvantum.enable = false;
    };
  };
}
