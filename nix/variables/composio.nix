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

  flake.modules.homeManager.default = { config, ... }: {
    sops.secrets."mcp/composio-key" = {
      sopsFile = "${clanDir}/vars/shared/composio/api-key/secret";
      format = "binary";
    };

    sops.secrets."mcp/composio-env" = {
      sopsFile = "${clanDir}/vars/shared/composio/env/secret";
      format = "binary";
    };

    xdg.configFile."environment.d/60-composio.conf".source =
      config.lib.file.mkOutOfStoreSymlink config.sops.secrets."mcp/composio-env".path;
  };
}
