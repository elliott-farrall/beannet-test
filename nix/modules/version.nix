{ ... }:

{
  clan.inventory.instances."state-version" = {
    module = {
      name = "state-version";
      input = "clan-core";
    };
    roles.default.tags."all" = {};
  };

  flake.modules.homeManager."default" = { nixosConfig, ... }: {
    home = { inherit (nixosConfig.system) stateVersion; };
  };
}
