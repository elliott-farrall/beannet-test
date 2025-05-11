{ inputs, ... }:

{
  flake.modules.nixos."machines/soy" = { lib, ... }: {
    imports = with inputs; [ nixos-wsl.nixosModules.default ];

    wsl = {
      enable = true;
      defaultUser = "elliott";
    };

    programs.nix-ld.enable = true;

    # FIXME - Need better fix for WSL file system
    preservation.enable = lib.mkForce false;
  };
}
