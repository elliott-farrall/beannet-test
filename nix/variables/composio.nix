{ config, ... }:

let
  clanDir = config.flake.clan.directory;
in
{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."composio" = {
      share = true;
      prompts."api-key" = {
        description = "Composio API key";
        type = "hidden";
        persist = true;
      };
      files."env".secret = true;
      script = ''
        printf 'COMPOSIO_API_KEY=' > "$out/env"
        tr -d '\n' < "$prompts/api-key" >> "$out/env"
      '';
    };
  };

  flake.modules.homeManager.default = { ... }: {
    sops.secrets."mcp/composio-key" = {
      sopsFile = "${clanDir}/vars/shared/composio/api-key/secret";
      format = "binary";
    };
  };
}
