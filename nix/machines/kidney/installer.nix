{ inputs, config, ... }:

with inputs.clan-core.nixosModules;
with config.flake.modules.nixos;
{
  flake.clan.machines."kidney" = { lib, ... }: {
    imports = [
      installer
      disks-flash
    ];

    disko.devices.disk."main".device = "/dev/null";

    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
    console.earlySetup = lib.mkForce true;

    nixpkgs.hostPlatform.system = "x86_64-linux";

    users.users.root.initialHashedPassword = lib.mkForce null;
  };
}
