{ ... }:

{
  flake.modules.nixos."default" = { pkgs, ... }: {
    boot.loader = {
      grub.useOSProber = true;
      grub.efiSupport = true;
      efi.canTouchEfiVariables = true;
    };

    environment.systemPackages = with pkgs; [ efibootmgr ];
  };
}
