{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    programs.starship = {
      enable = true;
      settings = {
        nix_shell.format = "via [$symbol($name)]($style) ";
      };
    };
  };

  flake.modules.homeManager."default" = { ... }: {
    programs.starship = {
      enable = true;
      settings = {
        nix_shell.format = "via [$symbol($name)]($style) ";
      };
    };

    stylix.targets.starship.enable = false;
  };
}
