{ inputs, ... }:

{
  flake.modules.nixos.default = { ... }: {
    imports = with inputs; [ catppuccin.nixosModules.catppuccin ];

    catppuccin = {
      enable = true;
      autoEnable = true;
      flavor = "macchiato";
      accent = "mauve";
    };
  };

  flake.modules.homeManager.default = { nixosConfig, ... }: {
    imports = with inputs; [ catppuccin.homeModules.catppuccin ];

    catppuccin = {
      inherit (nixosConfig.catppuccin) enable autoEnable flavor accent;

      # Targets managed by Stylix instead of Catppuccin.
      gtk.icon.enable = false;
      swaync.enable = false;

      # Themed via direct settings in the Hyprland Lua config.
      hyprland.enable = false;
    };
  };
}
