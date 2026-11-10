{ ... }:

{
  flake.modules.homeManager.default = { config, ... }: {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;

      settings = {
        model = "openrouter/openrouter/auto";
        provider.openrouter.options.apiKey = "{file:${config.sops.secrets."openrouter/api-key".path}}";
        permission = "allow";
      };
    };

    home.persistence.state.directories = [
      ".local/share/opencode"
    ];
  };
}
