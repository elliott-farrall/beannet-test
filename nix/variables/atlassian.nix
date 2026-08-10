{ config, ... }:

let
  clanDir = config.flake.clan.directory;
in
{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."atlassian" = {
      share = true;
      prompts."organisation" = {
        description = "Atlassian organisation name (e.g. my-org) — URL constructed as https://<org>.atlassian.net";
        type = "line";
        persist = true;
      };
      prompts."username" = {
        description = "Atlassian username (email address)";
        type = "line";
        persist = true;
      };
      prompts."mcp" = {
        description = "Atlassian API token";
        type = "hidden";
        persist = true;
      };
    };
  };

  flake.modules.homeManager.default = { ... }: {
    sops.secrets = {
      "mcp/atlassian-org" = { sopsFile = "${clanDir}/vars/shared/atlassian/organisation/secret"; format = "binary"; };
      "mcp/atlassian-user" = { sopsFile = "${clanDir}/vars/shared/atlassian/username/secret"; format = "binary"; };
      "mcp/atlassian-token" = { sopsFile = "${clanDir}/vars/shared/atlassian/mcp/secret"; format = "binary"; };
    };
  };
}
