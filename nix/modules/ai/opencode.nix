{ ... }:

{
  flake.modules.homeManager.default = { config, ... }: {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;

      settings = {
        model = "opencode-go/glm-5.3-flash";
        provider.opencode-go.options.apiKey = "{file:${config.sops.secrets."opencode-go/api-key".path}}";
        provider.openrouter.options.apiKey = "{file:${config.sops.secrets."openrouter/api-key".path}}";
        permission = "allow";
      };
    };

    home.persistence.state.directories = [
      ".local/share/opencode"
    ];
  };
}
