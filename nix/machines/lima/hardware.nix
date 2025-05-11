{ ... }:

{
  clan.machines."lima" = { lib, ... }: {
    display = {
      enable = true;
      output = "eDP-1";

      width = 2256;
      height = 1504;

      refresh = 60;

      scale = 1.333333;
    };

    boot.loader = {
      grub.efiSupport = lib.mkForce false;
      efi.canTouchEfiVariables = lib.mkForce false;
    };
  };
}
