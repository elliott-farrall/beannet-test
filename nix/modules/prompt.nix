{ ... }:

{
  flake.modules.homeManager.default = { ... }: {
    programs.starship.enable = true;

    stylix.targets.starship.enable = false; # Managed by Catppuccin
  };
}
