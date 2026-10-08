{ ... }:

{
  flake.modules.nixos.default = { config, lib, pkgs, ... }: {
    environment.persistence.state.directories = lib.mkIf config.networking.networkmanager.enable [
      "/etc/NetworkManager/system-connections"
    ];

    # Intel Wi-Fi cards (AX210) are prone to firmware hangs; power save is a
    # known aggravator. Keep it explicitly disabled.
    networking.networkmanager.wifi.powersave = false;

    # Recover from a wedged iwlwifi driver (Intel AX210 firmware hang) without
    # rebooting: if the radio is on but the device is unavailable or missing,
    # reload the driver so the card is re-initialised.
    systemd.services."networkmanager-wifi-recover" = lib.mkIf config.networking.networkmanager.enable {
      description = "Recover wedged Intel Wi-Fi by reloading the iwlwifi driver";
      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = 60;
      };
      script = ''
        radio=$(${pkgs.networkmanager}/bin/nmcli -t radio wifi 2>/dev/null)
        [ "$radio" = "enabled" ] || exit 0

        # A healthy device is connected or disconnected (interface up). If it is
        # unavailable or missing entirely, the driver is likely wedged.
        if ${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,TYPE,STATE device status 2>/dev/null \
          | ${pkgs.gnugrep}/bin/grep -q ':wifi:\(connected\|disconnected\)$'; then
          exit 0
        fi

        ${pkgs.coreutils}/bin/timeout 10 ${pkgs.networkmanager}/bin/nmcli radio wifi off || true
        ${pkgs.coreutils}/bin/sleep 3
        ${pkgs.kmod}/bin/modprobe -r iwlwifi || true
        ${pkgs.kmod}/bin/modprobe iwlwifi || true
        ${pkgs.coreutils}/bin/sleep 3
        ${pkgs.coreutils}/bin/timeout 10 ${pkgs.networkmanager}/bin/nmcli radio wifi on || true
      '';
    };

    systemd.timers."networkmanager-wifi-recover" = lib.mkIf config.networking.networkmanager.enable {
      description = "Periodic Wi-Fi health check";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "5min";
      };
    };
  };
}
