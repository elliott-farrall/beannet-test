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

  flake.clan.outputs.moduleForMachine = with config.flake.modules; {
    broad = nixos."default";
    kidney = nixos."default";
    lima = nixos."default";
    runner = nixos."default";
    soy = nixos."default";
    sprout = nixos."default";
  };
}
