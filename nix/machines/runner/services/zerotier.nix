{ ... }:

{
  flake.clan.machines."runner" = { lib, ... }:
    let
      ztIpv4Subnet = "10.147.17.0/24";
      # Runner's deterministic auto-assigned ZeroTier IPv4 address for the
      # Clan network (561b011a2726cc1e / node 561b011a27). Used as the
      # full-tunnel default gateway.
      gatewayIp = "10.147.17.97";
    in
    {
      # The Clan ZeroTier network is IPv6-only by default. Enable IPv4
      # assignment so Android clients can use full-tunnel mode and reach
      # runner's public services with a ZeroTier source IP, allowing Authelia
      # to bypass the SSO redirect for VPN members.
      clan.core.zerotier.networks.zerotier.settings = {
        v4AssignMode = lib.mkForce {
          zt = true;
        };
        ipAssignmentPools = lib.mkForce [
          {
            ipRangeStart = "10.147.17.1";
            ipRangeEnd = "10.147.17.254";
          }
        ];
        routes = lib.mkForce [
          # On-net route for the IPv4 pool; required for auto-assignment.
          { target = ztIpv4Subnet; }
          # Default route via runner lets Android full-tunnel clients route all
          # IPv4 traffic through the VPN.
          {
            target = "0.0.0.0/0";
            via = gatewayIp;
          }
        ];
      };

      # Masquerade VPN-sourced IPv4 traffic leaving runner's public interface.
      # Runner's Hetzner VM uses the predictable virtio name enp1s0.
      networking.nat = {
        enable = true;
        externalInterface = "enp1s0";
        internalIPs = [ ztIpv4Subnet ];
      };
    };
}
