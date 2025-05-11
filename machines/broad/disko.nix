{ modules, ... }:

{
  imports = with modules; [ nixos."disks/zfs" ];
  disko.devices.disk."main".device = "";
}
