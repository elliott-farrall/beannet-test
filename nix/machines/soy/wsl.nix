{ ... }:

{
  flake.clan.machines."soy" = { lib, ... }: {
    wsl.enable = true;
    networking.networkmanager.enable = lib.mkForce false;
    wsl.wslConf.network.generateHosts = false;
  };
}
