{ ... }:

{
  flake.clan.inventory.instances.zerotier = {
    roles.controller = {
      machines."runner" = { };
    };

    roles.peer = {
    };

    roles.moon = { };
  };

  flake.clan.inventory.instances.yggdrasil = {
    roles.default = {
      tags.all = { };
    };
  };
}
