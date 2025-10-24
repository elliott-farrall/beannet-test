{ config, ... }:

{
  flake.clan.inventory.instances."modules" = {
    module = {
      name = "importer";
      input = "clan-core";
    };

    roles.default = {
      tags."all" = { };

      extraModules = [
        { shell.zsh.enable = true; }
      ];
    };
  };

  flake.clan.outputs.moduleForMachine = with config.flake.modules.nixos; {
    broad = default;
    kidney = default;
    lima = default;
    runner = default;
    soy = default;
    sprout = default;
  };
}
