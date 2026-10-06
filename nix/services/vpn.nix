{ ... }:

{
  flake.clan.inventory.instances.zerotier = {
    roles.controller = {
      machines."runner".settings.allowedIds = [
        "fa9902098b"
      ];
    };

    roles.peer = {
      tags = [ "all" ];
    };

    roles.moon = { };
  };

  flake.clan.inventory.instances.yggdrasil = {
    roles.default = {
      tags = [ "all" ];
    };
  };
}
