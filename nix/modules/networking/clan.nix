{ ... }:

{
  flake.modules.nixos.default = { config, ... }: {
    clan.core.networking.targetHost = "${config.networking.hostName}.bean";
  };
}
