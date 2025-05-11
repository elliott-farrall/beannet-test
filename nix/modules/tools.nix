{ inputs, ... }:

{
  flake.modules.nixos."default" = { pkgs, ... }: {
    imports = with inputs; [ nix-index-database.nixosModules.nix-index ];

    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 30 --keep-since 14d";
      };
    };

    programs.nix-index-database.comma.enable = true;

    environment.systemPackages = with pkgs; [
      nil
      nix-fast-build
      nix-info
      nix-init
      nix-inspect
      nix-melt
      nix-output-monitor
      nix-tree
      nix-update
      nixd
      nixpkgs-hammering
    ];
  };
}
