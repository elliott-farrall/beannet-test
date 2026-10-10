{ config, ... }:

let
  clanDir = config.flake.clan.directory;
in
{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."terraform" = {
      share = true;
      prompts."mcp" = {
        description = "Terraform Cloud / Enterprise token";
        type = "hidden";
        persist = true;
      };
      files."env".secret = true;
      script = ''
        printf 'TFE_TOKEN=' > "$out/env"
        tr -d '\n' < "$prompts/mcp" >> "$out/env"
        printf '\n' >> "$out/env"
      '';
    };
  };

  flake.modules.homeManager.default = { ... }: {
    sops.secrets."mcp/terraform-token" = {
      sopsFile = "${clanDir}/vars/shared/terraform/mcp/secret";
      format = "binary";
    };
  };
}
