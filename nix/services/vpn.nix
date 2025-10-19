{ ... }:

{
  flake.clan.inventory.instances."beans" = {
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
