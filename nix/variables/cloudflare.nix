{ config, ... }:

let
  clanDir = config.flake.clan.directory;
in
{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."cloudflare" = {
      share = true;

      prompts."zone" = {
        description = "Cloudflare zone ID";
        type = "hidden";
        persist = true;
      };
      prompts."domain" = {
        description = "Domain managed by Cloudflare (e.g. example.com)";
        type = "line";
        persist = true;
      };
      prompts."dns-token" = {
        description = "Cloudflare API token with Zone:Read and DNS:Edit permissions (for DDNS and ACME)";
        type = "hidden";
        persist = true;
      };
      prompts."api-token" = {
        description = "Cloudflare API token for MCP (create at dash.cloudflare.com/profile/api-tokens)";
        type = "hidden";
        persist = true;
      };

      files."ddns-config.json" = { secret = true; };
      files."letsencrypt.env" = { secret = true; };

      script = ''
        cat > $out/ddns-config.json <<EOF
        {
          "settings": [
            {
              "provider": "cloudflare",
              "zone_identifier": "$(cat $prompts/zone)",
              "domain": "$(cat $prompts/domain)",
              "ttl": 1,
              "token": "$(cat $prompts/dns-token)"
            }
          ]
        }
        EOF

        cat > $out/letsencrypt.env <<EOF
        CLOUDFLARE_DNS_API_TOKEN=$(cat $prompts/dns-token)
        CLOUDFLARE_ZONE_API_TOKEN=$(cat $prompts/dns-token)
        EOF
      '';
    };
  };

  flake.modules.homeManager.default =
    { ... }:
    {
      sops.secrets."mcp/cloudflare-token" = {
        sopsFile = "${clanDir}/vars/shared/cloudflare/api-token/secret";
        format = "binary";
      };
    };
}
