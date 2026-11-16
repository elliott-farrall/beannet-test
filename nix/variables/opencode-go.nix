{ config, ... }:

let
  clanDir = config.flake.clan.directory;
in
{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."opencode-go" = {
      share = true;
      prompts."api-key" = {
        description = "OpenCode Go API key";
        type = "hidden";
        persist = true;
      };
      files."env".secret = true;
      script = ''
        printf 'OPENCODE_API_KEY=' > "$out/env"
        tr -d '\n' < "$prompts/api-key" >> "$out/env"
      '';
    };
  };

  flake.modules.homeManager.default = { ... }: {
    sops.secrets."opencode-go/api-key" = {
      sopsFile = "${clanDir}/vars/shared/opencode-go/api-key/secret";
      format = "binary";
    };
  };
}
