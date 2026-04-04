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

      settings.authorizedKeys."master" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUjxl1444qMm7/Xp2MTZIoU31m1j/UsThn5a3ql1lD2";

      # extraModules = [
      #   {
      #     clan.core.vars.generators."root-ssh-key" = {
      #       prompts."private-key" = {
      #         description = "root user private ssh key";
      #         type = "multiline-hidden";
      #         persist = true;
      #       };
      #       files."private-key".secret = true;

      #       prompts."public-key" = {
      #         description = "root user public ssh key";
      #         type = "line";
      #         persist = true;
      #       };
      #       files."public-key".secret = false;
      #     };
      #   }
      # ];
    };
  };
}
