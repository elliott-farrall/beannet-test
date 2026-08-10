{ ... }:

{
  flake.clan.inventory.instances."deploy" = {
    module = {
      name = "importer";
      input = "clan-core";
    };

    roles.default = {
      tags = [ "installer" "laptop" "wsl" ];

      extraModules = [{ clan.core.deployment.requireExplicitUpdate = true; }];
    };
  };
}
