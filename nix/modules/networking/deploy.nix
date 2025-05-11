{ ... }:

{
  flake.modules.nixos."default" = { config, ... }: {
    clan.core.networking.targetHost = config.clan.core.vars.generators.zerotiers.files.zerotier-ip.value;
  };
}
