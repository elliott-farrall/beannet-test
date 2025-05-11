{ lib, inputs, ... }:

{
  imports = with inputs.self.modules; [ nixos."machines/runner" ];

  clan.core.networking.targetHost = "root@88.198.151.191";

  boot.loader = {
    grub.efiSupport = lib.mkForce false;
    efi.canTouchEfiVariables = lib.mkForce false;
  };
}
