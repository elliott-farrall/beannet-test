{ inputs, ... }:

let
  inherit (inputs.clan-core.clan.machines) flash-installer;
  flashInstallerModule = builtins.elemAt (builtins.elemAt (builtins.elemAt flash-installer.imports 0).imports 0).imports 0;
in
{
  flake.clan.machines."kidney" = { lib, ... }: {
    imports = [ flashInstallerModule ];

    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  };
}
