{ ... }:

{
  flake.clan.inventory.instances."beans" = {
    module = {
      name = "zerotier";
      input = "clan-core";
    };

    roles.controller = {
      machines."runner" = { };
    };

    roles.peer = {
      tags."all" = { };
    };

    roles.moon = { };
  };
}
