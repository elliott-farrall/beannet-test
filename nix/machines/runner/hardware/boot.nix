{ ... }:

{
  flake.clan.machines."runner" = { lib, ... }: {
    boot.loader = {
      grub.efiSupport = lib.mkForce false;
      efi.canTouchEfiVariables = lib.mkForce false;
    };
  };
}
