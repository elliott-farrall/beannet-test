{ config, ... }:

let
  clanDir = config.flake.clan.directory;
in
{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."azure-devops" = {
      share = true;
      prompts."organisation" = {
        description = "Azure DevOps organisation name (e.g. my-org)";
        type = "line";
        persist = true;
      };
    };

    clan.core.vars.generators."azure" = {
      share = true;
      prompts."tenant-id" = {
        description = "Azure tenant ID for the service principal";
        type = "hidden";
        persist = true;
      };
      prompts."client-id" = {
        description = "Azure service principal client (application) ID";
        type = "hidden";
        persist = true;
      };
      prompts."client-secret" = {
        description = "Azure service principal client secret";
        type = "hidden";
        persist = true;
      };

      files."env".secret = true;
      script = ''
        {
          printf 'AZURE_TENANT_ID='; tr -d '\n' < "$prompts/tenant-id"; printf '\n'
          printf 'AZURE_CLIENT_ID='; tr -d '\n' < "$prompts/client-id"; printf '\n'
          printf 'AZURE_CLIENT_SECRET='; tr -d '\n' < "$prompts/client-secret"; printf '\n'
        } > "$out/env"
      '';
    };
  };

  flake.modules.homeManager.default = { ... }: {
    sops.secrets = {
      "mcp/ado-org" = { sopsFile = "${clanDir}/vars/shared/azure-devops/organisation/secret"; format = "binary"; };
      "mcp/azure-tenant-id" = { sopsFile = "${clanDir}/vars/shared/azure/tenant-id/secret"; format = "binary"; };
      "mcp/azure-client-id" = { sopsFile = "${clanDir}/vars/shared/azure/client-id/secret"; format = "binary"; };
      "mcp/azure-client-secret" = { sopsFile = "${clanDir}/vars/shared/azure/client-secret/secret"; format = "binary"; };
    };
  };
}
