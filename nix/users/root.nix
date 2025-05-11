{ ... }:

{
  flake.clan.inventory.instances."root" = {
    module.name = "admin";
    roles.default.tags."nodes" = { };

    roles.default.settings.allowedKeys = {
      "ed25519" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUjxl1444qMm7/Xp2MTZIoU31m1j/UsThn5a3ql1lD2";
    };
  };
}
