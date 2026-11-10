{ ... }:

{
  flake.modules.homeManager.default = { ... }: {
    programs.mcp = {
      enable = true;

      servers."composio".url = "https://connect.composio.dev/mcp";
    };
  };
}
