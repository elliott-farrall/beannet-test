{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    programs.starship.enable = true;
  };

  flake.modules.homeManager.default = { ... }: {
    programs.starship.enable = true;

    stylix.targets.starship.enable = false;
  };
}
