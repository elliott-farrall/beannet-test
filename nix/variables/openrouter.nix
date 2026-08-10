{ config, ... }:

let
  clanDir = config.flake.clan.directory;
in
{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."openrouter" = {
      share = true;
      prompts."api-key" = {
        description = "OpenRouter API key (from https://openrouter.ai/settings/keys)";
        type = "hidden";
        persist = true;
      };
    };
  };

  flake.modules.homeManager.default = { ... }: {
    sops.secrets."openrouter/api-key" = {
      sopsFile = "${clanDir}/vars/shared/openrouter/api-key/secret";
      format = "binary";
    };
    sops.secrets."mcp/openrouter-key" = {
      sopsFile = "${clanDir}/vars/shared/openrouter/api-key/secret";
      format = "binary";
    };
  };
}
