{ ... }:

{
  flake.modules.nixos."shared" = { ... }: {
    clan.core.networking.zerotier.networkId = builtins.readFile ../../../vars/per-machine/runner/zerotier/zerotier-network-id/value;
  };
}
