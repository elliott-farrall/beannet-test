{ inputs, ... }:

{
  flake.clan.machines."soy" = { lib, ... }: {
    imports = with inputs; [ nixos-wsl.nixosModules.default ];

    wsl = {
      enable = true;
      defaultUser = "elliott";
    };

    programs.nix-ld.enable = true;

    # FIXME - Need better fix for WSL file system
    environment.persistence.data.enable = lib.mkForce false;
    environment.persistence.state.enable = lib.mkForce false;
    environment.persistence.log.enable = lib.mkForce false;
  };
}
