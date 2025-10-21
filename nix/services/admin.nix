{ ... }:

{
  flake.clan.inventory.instances."admin" = {
    module = {
      name = "admin";
      input = "clan-core";
    };

    roles.default = {
      tags."all" = { };

      settings.allowedKeys."master" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUjxl1444qMm7/Xp2MTZIoU31m1j/UsThn5a3ql1lD2";

      extraModules = [
        {
          clan.core.vars.generators."root" = {
            share = true;

            prompts."private-key" = {
              description = "root user private ssh key";
              type = "multiline-hidden";
              persist = true;
            };
          };
        }
      ];
    };
  };
}
