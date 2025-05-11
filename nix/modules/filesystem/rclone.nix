{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    programs.fuse.userAllowOther = true; # Enables --allow-other in rclone mount;

    # FIXME : Come up with better solution for giving rclone access to secrets
    sops.secrets = {
      "rclone_DotFiles-id".mode = "0644";
      "rclone_DotFiles-key".mode = "0644";
      "rclone_DotFiles-url".mode = "0644";
      "rclone_DropBox-token".mode = "0644";
      "rclone_Google-token".mode = "0644";
      "rclone_OneDrive-id".mode = "0644";
      "rclone_OneDrive-token".mode = "0644";
      "rclone_Work-id".mode = "0644";
      "rclone_Work-token".mode = "0644";
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
          access_key_id = nixosConfig.sops.secrets."rclone_DotFiles-id".path;
          secret_access_key = nixosConfig.sops.secrets."rclone_DotFiles-key".path;
          endpoint = nixosConfig.sops.secrets."rclone_DotFiles-url".path;
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
          token = nixosConfig.sops.secrets."rclone_DropBox-token".path;
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
          token = nixosConfig.sops.secrets."rclone_Google-token".path;
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
          drive_id = nixosConfig.sops.secrets."rclone_OneDrive-id".path;
          token = nixosConfig.sops.secrets."rclone_OneDrive-token".path;
        };
        mounts."/" = {
          enable = true;
          mountPoint = "${config.xdg.configHome}/rclone/mnt/OneDrive";
        };
      };

      /* ---------------------------------- Work ---------------------------------- */

      # remotes."Work" = {
      #   config = {
      #     type = "onedrive";
      #     drive_type = "business";
      #   };
      #   secrets = {
      #     drive_id = nixosConfig.sops.secrets."rclone_Work-id".path;
      #     token = nixosConfig.sops.secrets."rclone_Work-token".path;
      #   };
      #   mounts."/" = {
      #     enable = true;
      #     mountPoint = "${config.xdg.configHome}/rclone/mnt/Work";
      #   };
      # };
    };
  };
}
