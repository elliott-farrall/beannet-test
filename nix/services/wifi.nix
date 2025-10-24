{ ... }:

{
  flake.clan.inventory.instances."wifi" = {
    module = {
      name = "wifi";
      input = "clan-core";
    };

    roles.default = {
      tags."laptop" = { };

      settings = {
        networks."beannet" = { };
      };
    };
  };
}
