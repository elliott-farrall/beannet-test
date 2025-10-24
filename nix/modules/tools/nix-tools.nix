{ ... }:

{
  flake.modules.nixos.default = { pkgs, ... }: {
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
