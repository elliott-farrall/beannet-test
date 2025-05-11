{ inputs, ... }:

let
  inherit (inputs.clan-core.clan.machines) flash-installer;
  flashInstallerModule = builtins.elemAt (builtins.elemAt (builtins.elemAt flash-installer.imports 0).imports 0).imports 0;
in
{
  flake.clan.machines."kidney" = { ... }: {
    imports = [ flashInstallerModule ];

    /* -------------------------------- Language -------------------------------- */

    i18n.defaultLocale = "en_GB.UTF-8";

    /* --------------------------------- Keymap --------------------------------- */

    services.xserver.xkb.layout = "uk";

    /* ---------------------------------- Keys ---------------------------------- */

    # TODO - Drop this and use clanService
    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUjxl1444qMm7/Xp2MTZIoU31m1j/UsThn5a3ql1lD2"
    ];
    clan.core.vars.generators."root" = {
      share = true;

      prompts."private-key" = {
        description = "root user private ssh key";
        type = "multiline-hidden";
        persist = true;
      };
    };
  };
}
