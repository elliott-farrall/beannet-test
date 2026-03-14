{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    services.ollama.enable = true;
  };
}
