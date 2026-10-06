{ ... }:

{
  flake.clan.machines."runner" = { lib, pkgs, config, ... }:
    let
      networkId = config.clan.core.vars.generators."zerotier-network-zerotier".files.network-id.value;
      # ZeroTier node ID is the first 10 hex chars of the network ID.
      nodeId = builtins.substring 0 10 networkId;

      # The controller's IPv4 auto-assignment algorithm uses the least
      # significant 32 bits of the node ID modulo the pool size. Reproduce that
      # here so the default-route gateway matches runner's actual assigned IP.
      hexChars = lib.stringToCharacters "0123456789abcdef";
      hexCharToInt = c: lib.lists.findFirstIndex (d: d == c) (throw "invalid hex char ${c}") hexChars;
      hexToInt = s: lib.foldl (acc: c: acc * 16 + hexCharToInt c) 0 (lib.stringToCharacters (lib.toLower s));
      nodeIdLsb32 = hexToInt (builtins.substring 2 8 nodeId);

      ipRangeStart = 10 * 16777216 + 147 * 65536 + 17 * 256 + 1; # 10.147.17.1
      ipRangeLen = 253;
      gatewayInt = ipRangeStart + (lib.mod nodeIdLsb32 ipRangeLen);
      gatewayOctets = [
        (builtins.div gatewayInt 16777216)
        (lib.mod (builtins.div gatewayInt 65536) 256)
        (lib.mod (builtins.div gatewayInt 256) 256)
        (lib.mod gatewayInt 256)
      ];
      gatewayIp = lib.concatStringsSep "." (map toString gatewayOctets);

      ztIpv4Subnet = "10.147.17.0/24";
    in
    {
      # The Zerotier network is IPv6-only by default. Enable IPv4 assignment
      # so Android clients can use full-tunnel mode and still reach runner's
      # public services with a Zerotier source IP, allowing Authelia to bypass
      # the SSO redirect for VPN members.
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
          # An on-net route for the IPv4 pool is required for the controller to
          # auto-assign addresses from it.
          { target = ztIpv4Subnet; }
          # Default route via runner lets Android "full tunnel" clients route
          # all IPv4 traffic through the VPN. The gateway must be runner's
          # auto-assigned ZeroTier IPv4 address, which is derived above.
          {
            target = "0.0.0.0/0";
            via = gatewayIp;
          }
        ];
      };

      # Allow IPv4 traffic from the Zerotier tunnel to be forwarded when
      # full-tunnel clients want general internet access.
      boot.kernel.sysctl."net.ipv4.ip_forward" = true;

      # Masquerade VPN-sourced IPv4 traffic leaving runner's public interface.
      # Runner's Hetzner VM uses the predictable virtio name enp1s0.
      networking.nat.enable = true;
      networking.nat.externalInterface = "enp1s0";
      networking.nat.internalIPs = [ ztIpv4Subnet ];

      # Remove any stale static IPv4 assignment left over from the earlier
      # attempt to pin runner to 10.147.17.1. The gateway now follows the
      # controller's auto-assigned address (10.147.17.97), so a fixed .1 would
      # conflict with the default route.
      systemd.services.zerotierone.serviceConfig.ExecStartPre = lib.mkAfter [
        ("+" + (pkgs.writeShellScript "zerotier-cleanup-runner-ip" ''
          member_file=/var/lib/zerotier-one/controller.d/network/${networkId}/member/${nodeId}
          if [ -f "$member_file" ]; then
            ${pkgs.jq}/bin/jq 'del(.ipAssignments)' "$member_file" > "$member_file.tmp" && \
              mv "$member_file.tmp" "$member_file"
          fi
        ''))
      ];
    };
}
