{ config, ... }:

let
  clanDir = config.flake.clan.directory;
in
{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."cloudflare" = {
      share = true;

      prompts."email" = {
        description = "Cloudflare account email";
        type = "line";
        persist = true;
      };
      prompts."key" = {
        description = "Cloudflare Global API key";
        type = "hidden";
        persist = true;
      };
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
      prompts."api-token" = {
        description = "Cloudflare API token for MCP (create at dash.cloudflare.com/profile/api-tokens)";
        type = "hidden";
        persist = true;
      };

      files."ddns-config.json" = { };
      files."letsencrypt.env" = { };

      script = ''
        cat > $out/ddns-config.json <<EOF
        {
          "settings": [
            {
              "provider": "cloudflare",
              "zone_identifier": "$(cat $prompts/zone)",
              "domain": "$(cat $prompts/domain)",
              "ttl": 1,
              "email": "$(cat $prompts/email)",
              "key": "$(cat $prompts/key)"
            }
          ]
        }
        EOF

        cat > $out/letsencrypt.env <<EOF
        CF_API_EMAIL=$(cat $prompts/email)
        CF_API_KEY=$(cat $prompts/key)
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
