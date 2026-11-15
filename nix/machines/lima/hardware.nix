{ inputs, config, ... }:

with inputs.nixos-hardware.nixosModules;
with config.flake.modules.nixos;
{
  flake.clan.machines."lima" = { ... }: {
    imports = [
      framework-12th-gen-intel
      disks-zfs
    ];

    disko.devices.disk."main".device = "/dev/disk/by-id/nvme-Samsung_SSD_970_PRO_512GB_S463NF0K800096J";

    networking.networkmanager.enable = true;

    devices.audio.enable = true;
    devices.bluetooth.enable = true;
    devices.printing.enable = true;

    devices.display = {
      enable = true;
      output = "eDP-1";

      width = 2256;
      height = 1504;

      refresh = 60;

      scale = 1.333333;
    };

    # Thermal management — required for Framework 12th-gen (no built-in thermal daemon)
    services.thermald.enable = true;

    # CPU frequency scaling governor — powersave avoids max-turbo throttling under light load
    powerManagement.cpuFreqGovernor = "powersave";

    # Disable turbo boost — runs after intel_pstate loads (during early boot)
    systemd.services.disable-turbo-boost.serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/bash -c 'echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo'";
      Restart = "no";
    };
    systemd.services.disable-turbo-boost.wantedBy = [ "multi-user.target" ];

    # PCI Express ASPM (Active State Power Management) — saves power on idle buses
    boot.kernelParams = [ "pcie_aspm.policy=powersave" ];

    # Intel GPU panel self-refresh when possible, disable DC6 to avoid resume latency
    boot.extraModprobeConfig = ''
      options i915 enable_psr=1 enable_dc=0 enable_fbc=1
    '';
  };
}
