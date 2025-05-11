{ inputs, config, ... }:

{
  flake.clan.machines."lima" = { ... }: {
    imports = [
      inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
      config.flake.modules.nixos."disks/zfs"
    ];

    disko.devices.disk."main".device = "/dev/disk/by-id/nvme-Samsung_SSD_970_PRO_512GB_S463NF0K800096J";

    clan.core.networking.targetHost = "";

    display = {
      enable = true;
      output = "eDP-1";

      width = 2256;
      height = 1504;

      refresh = 60;

      scale = 1.333333;
    };
  };
}
