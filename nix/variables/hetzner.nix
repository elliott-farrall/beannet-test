{ config, ... }:

let
  clanDir = config.flake.clan.directory;
in
{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."hetzner" = {
      share = true;
      prompts."cloud-token" = {
        description = "Hetzner Cloud API token (create at https://console.hetzner.cloud → project → Security → API Tokens → Read/Write)";
        type = "hidden";
        persist = true;
      };
    };
  };

  flake.modules.homeManager.default = { ... }: {
    sops.secrets."mcp/hetzner-token" = {
      sopsFile = "${clanDir}/vars/shared/hetzner/cloud-token/secret";
      format = "binary";
    };
  };
}
