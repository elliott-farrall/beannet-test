{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    services.ollama = {
      enable = true;
      loadModels = [ "qwen3:1.7b" ];
    };
  };
}
