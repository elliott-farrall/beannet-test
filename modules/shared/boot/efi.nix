{ ... }:

{
  flake.modules.nixos."shared" = { pkgs, ... }: {
    boot.loader = {
      grub.efiSupport = true;
      efi.canTouchEfiVariables = true;
    };

    environment.systemPackages = with pkgs; [ efibootmgr ];
  };
}
