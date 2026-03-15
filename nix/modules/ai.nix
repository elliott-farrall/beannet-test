{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    services.ollama = {
      enable = false;
      loadModels = [ "qwen3:1.7b" ];
    };
  };
}
