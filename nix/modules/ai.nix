{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    services.ollama = {
      enable = true;
      loadModels = [ "qwen3:1.7b" ];
    };
  };

  flake.modules.homeManager.default = { ... }: {
    home.persistence.state = {
      directories = [ ".claude" ];
      files = [ ".claude.json" ];
    };
  };
}
