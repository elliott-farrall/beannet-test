{ ... }:

{
  flake.modules.nixos."programs/nemo" = { pkgs, ... }: {
    # Enable gvfs for trash and recents support in file managers
    services.gvfs.enable = true;

    # Issues with org.gtk.vfs.UDisks2VolumeMonitor, causes slow file-managers
    environment.sessionVariables.GVFS_REMOTE_VOLUME_MONITOR_IGNORE = "true";

    # Enable automated trash emptying
    services.cron = {
      enable = true;
      systemCronJobs = [ "@hourly ${pkgs.trash-cli}/bin/trash-empty --all-users -f 30" ];
    };
  };

  flake.modules.homeManager."programs/nemo" = { lib, pkgs, config, ... }: {
    home.packages = with pkgs; [
      nemo-with-extensions
      nemo-fileroller
    ];

    programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
      "nemo" = "󰪶";
    };
  };
}
