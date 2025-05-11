{ ... }:

{
  flake.modules.nixos."default" = { config, ... }: {
    clan.core.networking.targetHost = "[${config.clan.core.vars.generators.zerotier.files.zerotier-ip.value}]";
  };
}
