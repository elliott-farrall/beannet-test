{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    clan.core.vars.generators."rclone-dotfiles" = {
      share = true;

      files."id".owner = "elliott";
      files."key".owner = "elliott";
      files."url".owner = "elliott";

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
  };

  flake.modules.homeManager."default" = { config, nixosConfig, ... }: {
    programs.rclone.remotes."DotFiles" = {
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
  };
}
