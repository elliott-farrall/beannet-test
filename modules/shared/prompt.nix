{ ... }:

{
  flake.modules.nixos."shared" = {  ... }: {
    programs.starship = {
      enable = true;
      settings = {
        nix_shell.format = "via [$symbol($name)]($style) ";
      };
    };
  };

  flake.modules.homeManager."shared" = {  ... }: {
    programs.starship = {
      enable = true;
      settings = {
        nix_shell.format = "via [$symbol($name)]($style) ";
      };
    };
  };
}
