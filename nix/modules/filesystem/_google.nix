{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    clan.core.vars.generators."rclone-google" = {
      share = true;

      prompts."token" = {
        description = "google drive token";
        type = "hidden";
        persist = true;
      };
    };
  };

  flake.modules.homeManager."default" = { config, nixosConfig, ... }: {
    programs.rclone.remotes."Google" = {
      config = {
        type = "drive";
      };
      secrets = {
        token = nixosConfig.clan.core.vars.generators."rclone-google".files."token".path;
      };
      mounts."/" = {
        enable = true;
        mountPoint = "${config.xdg.configHome}/rclone/mnt/Google";
      };
    };
  };
}
