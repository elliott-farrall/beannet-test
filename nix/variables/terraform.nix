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
    };
  };

  flake.modules.homeManager.default = { ... }: {
    sops.secrets."mcp/terraform-token" = {
      sopsFile = "${clanDir}/vars/shared/terraform/mcp/secret";
      format = "binary";
    };
  };
}
