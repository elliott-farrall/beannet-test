{ inputs, ... }:

{
  flake.modules.nixos.default = { ... }: {
    imports = with inputs; [ catppuccin.nixosModules.catppuccin ];

    catppuccin = {
      enable = true;
      flavor = "macchiato";
      accent = "mauve";
    };
  };

  flake.modules.homeManager.default = { nixosConfig, ... }: {
    imports = with inputs; [ catppuccin.homeModules.catppuccin ];

    catppuccin = {
      inherit (nixosConfig.catppuccin) enable flavor accent;
      gtk.icon.enable = false; # Managed by Stylix
    };
  };
}
