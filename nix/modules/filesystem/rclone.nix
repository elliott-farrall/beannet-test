{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    programs.fuse.userAllowOther = true; # Enables --allow-other in rclone mount;

    clan.core.vars.generators."rclone-dotfiles" = {
      share = true;

      prompts."id" = {
        description = "dotfiles access key id";
        type = "hidden";
        persist = true;
      };
      prompts."key" = {
        description = "dotfiles secret access key";
        type = "hidden";
        persist = true;
      };
      prompts."url" = {
        description = "dotfiles endpoint";
        persist = true;
      };
    };

    clan.core.vars.generators."rclone-dropbox" = {
      share = true;

      prompts."token" = {
        description = "dropbox token";
        type = "hidden";
        persist = true;
      };
    };

    clan.core.vars.generators."rclone-google" = {
      share = true;

      prompts."token" = {
        description = "google drive token";
        type = "hidden";
        persist = true;
      };
    };

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
    programs.rclone = {
      enable = true;

      /* -------------------------------- DotFiles -------------------------------- */

      remotes."DotFiles" = {
        config = {
          type = "s3";
          provider = "Cloudflare";
        };
        secrets = {
          access_key_id = nixosConfig.clan.core.vars.generators."rclone-dotfiles".files."id".path;
          secret_access_key = nixosConfig.clan.core.vars.generators."rclone-dotfiles".files."key".path;
          endpoint = nixosConfig.clan.core.vars.generators."rclone-dotfiles".files."url".path;
        };
        mounts."/dotfiles" = {
          enable = true;
          mountPoint = "${config.xdg.configHome}/rclone/mnt/DotFiles";
        };
      };

      /* --------------------------------- DropBox -------------------------------- */

      remotes."DropBox" = {
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

      /* --------------------------------- Google --------------------------------- */

      remotes."Google" = {
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

      /* -------------------------------- OneDrive -------------------------------- */

      remotes."OneDrive" = {
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
  };
}
