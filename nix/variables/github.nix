{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."github" = {
      share = true;
      prompts."mcp" = {
        description = "GitHub PAT (scopes: copilot, repo, read:user)";
        type = "hidden";
        persist = true;
      };
    };
  };
}
