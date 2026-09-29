{ ... }:

{
  flake.modules.nixos.default = { lib, pkgs, config, ... }: {
    options = {
      applications.nemo.enable = pkgs.lib.mkEnableOption "the Nemo application";
    };

    config = lib.mkIf config.applications.nemo.enable {
      # Enable gvfs for trash and recents support in file managers
      services.gvfs.enable = true;

      # Issues with org.gtk.vfs.UDisks2VolumeMonitor, causes slow file-managers
      environment.sessionVariables.GVFS_REMOTE_VOLUME_MONITOR_IGNORE = "true";

      # Automated trash emptying is handled by the home-manager user timer below.
    };
  };

  flake.modules.homeManager.default = { lib, pkgs, config, ... }: {
    options = {
      applications.nemo.enable = pkgs.lib.mkEnableOption "the Nemo application";
    };

    config = lib.mkIf config.applications.nemo.enable {
      home.packages = with pkgs; [
        nemo-with-extensions
        nemo-fileroller
      ];

      desktop.wmIcons."nemo" = "󰪶";

      systemd.user.services.trash-empty = {
        Unit.Description = "Empty user trash older than 30 days";
        Service = {
          Type = "oneshot";
          ExecStart = "${pkgs.trash-cli}/bin/trash-empty -f 30";
        };
      };

      systemd.user.timers.trash-empty = {
        Unit.Description = "Run trash-empty hourly";
        Timer = {
          OnCalendar = "hourly";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
    };
  };
}
