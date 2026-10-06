{ lib, ... }:

{
  flake.clan.machines."runner" = { ... }:
    let
      # Runner's deterministic auto-assigned ZeroTier IPv6 address for the
      # Clan network 561b011a2726cc1e / node 561b011a27.
      ztIpv6 = "fd56:1b01:1a27:26cc:1e99:9356:1b01:1a27";
      # ZeroTier RFC4193 ULA /64 for the Clan network.
      ztIpv6Subnet = "fd56:1b01:1a27:26cc::/64";
    in
    {
      # The Clan ZeroTier network is IPv6-only by default. Rather than
      # assigning IPv4 addresses and routing all traffic through runner, push
      # DNS for bean.directory so VPN clients resolve *.bean.directory to
      # runner's ZeroTier IPv6 address. Traffic then stays on the VPN and
      # Authelia sees the ZeroTier IPv6 subnet.
      clan.core.zerotier.networks.zerotier.settings = {
        dns = lib.mkForce {
          domain = "bean.directory";
          servers = [ ztIpv6 ];
        };
      };

      # Lightweight DNS resolver for VPN clients.
      services.dnsmasq = {
        enable = true;
        extraConfig = ''
          bind-dynamic
          listen-address=${ztIpv6}
          server=1.1.1.1
          server=2606:4700:4700::1111
          address=/bean.directory/${ztIpv6}
        '';
      };

      systemd.services.dnsmasq = {
        after = [ "zerotierone.service" ];
        wants = [ "zerotierone.service" ];
      };

      # Allow DNS queries from the ZeroTier IPv6 subnet.
      networking.firewall.extraCommands = ''
        ip6tables -A nixos-fw -s ${ztIpv6Subnet} -p udp --dport 53 -j nixos-fw-accept
        ip6tables -A nixos-fw -s ${ztIpv6Subnet} -p tcp --dport 53 -j nixos-fw-accept
      '';
    };
}
