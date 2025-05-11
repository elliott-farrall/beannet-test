{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    services.avahi = {
      enable = true;
      nssmdns4 = true; # TODO - IPv6 for VPN?

      publish = {
        enable = true;
        addresses = true;
      };
    };
  };
}
