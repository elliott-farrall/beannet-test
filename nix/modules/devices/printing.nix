{ ... }:

{
  flake.modules.nixos."devices/printing" = { ... }: {
    services.printing.enable = true;
    services.colord.enable = true;
  };
}
