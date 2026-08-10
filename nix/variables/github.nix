{ config, ... }:

let
  clanDir = config.flake.clan.directory;
in
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

  flake.modules.homeManager.default = { ... }: {
    sops.secrets."mcp/github-token" = {
      sopsFile = "${clanDir}/vars/shared/github/mcp/secret";
      format = "binary";
    };
  };
}
