{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    services.kmscon.enable = true;
  };
}
