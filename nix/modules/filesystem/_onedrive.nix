{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    clan.core.vars.generators."rclone-onedrive" = {
      share = true;

      prompts."id" = {
        description = "onedrive drive id";
        type = "hidden";
        persist = true;
      };
      prompts."token" = {
        description = "onedrive token";
        type = "hidden";
        persist = true;
      };
    };
  };

  flake.modules.homeManager."default" = { config, nixosConfig, ... }: {
    programs.rclone.remotes."OneDrive" = {
      config = {
        type = "onedrive";
        drive_type = "personal";
      };
      secrets = {
        drive_id = nixosConfig.clan.core.vars.generators."rclone-onedrive".files."id".path;
        token = nixosConfig.clan.core.vars.generators."rclone-onedrive".files."token".path;
      };
      mounts."/" = {
        enable = true;
        mountPoint = "${config.xdg.configHome}/rclone/mnt/OneDrive";
      };
    };
  };
}
