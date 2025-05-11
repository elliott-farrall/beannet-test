{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    programs.fuse.userAllowOther = true; # Enables --allow-other in rclone mount
  };

  flake.modules.homeManager."default" = { pkgs, config, nixosConfig, ... }:
    let
      mkService = { name, mount ? "${config.xdg.configHome}/rclone/mnt", path ? "/" }: {
        Unit = {
          Description = "Mount for ${name}";
          X-SwitchMethod = "keep-old"; #TODO - Come up with better fix for rclone mounts failing on login
        };
        Service = {
          Type = "notify";
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mount}/${name}";
          ExecStart = "${pkgs.rclone}/bin/rclone mount ${name}:${path} ${mount}/${name} --allow-other --file-perms 0777 --vfs-cache-mode writes";
          ExecStop = "/run/wrappers/bin/fusermount -u ${mount}/${name}";
          Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    in
    {
      programs.rclone = {
        enable = true;

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
        };
        remotes."DropBox" = {
          config = {
            type = "dropbox";
          };
          secrets = {
            token = nixosConfig.sops.secrets."rclone_DropBox-token".path;
          };
        };
        remotes."Google" = {
          config = {
            type = "drive";
          };
          secrets = {
            token = nixosConfig.sops.secrets."rclone_Google-token".path;
          };
        };
        remotes."OneDrive" = {
          config = {
            type = "onedrive";
            drive_type = "personal";
          };
          secrets = {
            drive_id = nixosConfig.sops.secrets."rclone_OneDrive-id".path;
            token = nixosConfig.sops.secrets."rclone_OneDrive-token".path;
          };
        };
        remotes."Work" = {
          config = {
            type = "onedrive";
            drive_type = "business";
          };
          secrets = {
            drive_id = nixosConfig.sops.secrets."rclone_Work-id".path;
            token = nixosConfig.sops.secrets."rclone_Work-token".path;
          };
        };
      };

      systemd.user = {
        services."rclone-DotFiles" = mkService { name = "DotFiles"; path = "/dotfiles"; };
        services."rclone-DropBox" = mkService { name = "DropBox"; };
        services."rclone-Google" = mkService { name = "Google"; };
        services."rclone-OneDrive" = mkService { name = "OneDrive"; };
        services."rclone-Work" = mkService { name = "Work"; };
      };
    };
}
