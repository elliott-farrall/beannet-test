{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    programs.fuse.userAllowOther = true; # Enables --allow-other in rclone mount;
  };

  flake.modules.homeManager."default" = { ... }: {
    programs.rclone.enable = true;
  };
}
