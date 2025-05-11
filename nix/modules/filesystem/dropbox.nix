{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    clan.core.vars.generators."rclone-dropbox" = {
      share = true;

      prompts."token" = {
        description = "dropbox token";
        type = "hidden";
        persist = true;
      };
    };
  };

  flake.modules.homeManager."default" = { config, nixosConfig, ... }: {
    programs.rclone.remotes."DropBox" = {
      config = {
        type = "dropbox";
      };
      secrets = {
        token = nixosConfig.clan.core.vars.generators."rclone-dropbox".files."token".path;
      };
      mounts."/" = {
        enable = true;
        mountPoint = "${config.xdg.configHome}/rclone/mnt/DropBox";
      };
    };
  };
}
