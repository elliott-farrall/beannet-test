{ inputs, ... }:

{
  flake.modules.nixos."default" = { ... }: {
    imports = with inputs; [ nix-index-database.nixosModules.nix-index ];
    programs.nix-index-database.comma.enable = true;
  };
}
