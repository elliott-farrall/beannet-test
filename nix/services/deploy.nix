{ ... }:

{
  flake.clan.inventory.instances."deploy" = {
    module = {
      name = "importer";
      input = "clan-core";
    };

    roles.default = {
      tags."installer" = { };
      tags."laptop" = { };
      tags."wsl" = { };

      extraModules = [{ clan.core.deployment.requireExplicitUpdate = true; }];
    };
  };
}
