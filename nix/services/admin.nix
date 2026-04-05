{ ... }:

{
  flake.clan.inventory.instances."root" = {
    module = {
      name = "users";
      input = "clan-core";
    };

    roles.default = {
      tags = [ "all" ];

      settings = {
        user = "root";
        prompt = true;
      };
    };
  };

  flake.clan.inventory.instances."sshd" = {
    module = {
      name = "sshd";
      input = "clan-core";
    };

    roles.server = {
      tags."all" = { };

      settings.generateRootKey = true;
    };
  };
}
