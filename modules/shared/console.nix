{ ... }:

{
  flake.modules.nixos."shared" = { ... }: {
    services.kmscon.enable = true;
  };
}
