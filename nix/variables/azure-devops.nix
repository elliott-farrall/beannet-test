{ ... }:

{
  flake.modules.nixos.default = { pkgs, ... }: {
    clan.core.vars.generators."azure-devops" = {
      share = true;

      prompts."organisation" = {
        description = "Azure DevOps organisation name (e.g. my-org)";
        type = "line";
        persist = true;
      };

      files."env".secret = true;
      files."mcp-auth".secret = true;
      runtimeInputs = [ pkgs.openssl ];
      script = ''
        printf 'ADO_ORG=' > "$out/env"
        tr -d '\n' < "$prompts/organisation" >> "$out/env"
        printf '\n' >> "$out/env"
        printf 'TOKEN_AZURE_DEVOPS=' > "$out/mcp-auth"
        openssl rand -hex 32 >> "$out/mcp-auth"
      '';
    };
  };
}
