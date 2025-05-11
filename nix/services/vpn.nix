{ ... }:

{
  flake.clan.inventory.instances."beannet" = {
    module = {
      name = "zerotier";
      input = "clan-core";
    };
    roles = {
      controller.machines."runner" = { };
      peer.tags."all" = { };
      moon = { };
    };
  };
}
