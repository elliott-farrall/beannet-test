{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    services.avahi = {
      enable = true;
      nssmdns4 = true;

      publish = {
        enable = true;
        addresses = true;
      };
    };
  };
}
