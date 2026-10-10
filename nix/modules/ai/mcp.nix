{ ... }:

{
  flake.modules.homeManager.default = { ... }: {
    programs.mcp = {
      enable = true;

      servers."composio" = {
        url = "https://connect.composio.dev/mcp";
        headers."x-consumer-api-key" = "{env:COMPOSIO_API_KEY}";
      };
    };
  };
}
