{ ... }:

{
  flake.modules.homeManager.default =
    { config, pkgs, ... }:
    {
      programs.mcp = {
        enable = true;

        servers."github".command = toString (pkgs.writeShellScript "mcp-github" ''
          export GITHUB_PERSONAL_ACCESS_TOKEN=$(< ${config.sops.secrets."mcp/github-token".path})
          exec ${pkgs.github-mcp-server}/bin/github-mcp-server stdio
        '');

        servers."nixos".command = toString (pkgs.writeShellScript "mcp-nixos" ''
          exec ${pkgs.mcp-nixos}/bin/mcp-nixos
        '');

        servers."context7".command = toString (pkgs.writeShellScript "mcp-context7" ''
          exec ${pkgs.context7-mcp}/bin/context7-mcp
        '');

        servers."sequential-thinking".command = toString (pkgs.writeShellScript "mcp-sequential-thinking" ''
          exec ${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking
        '');

        servers."cloudflare".command = toString (pkgs.writeShellScript "mcp-cloudflare" ''
          export CLOUDFLARE_API_TOKEN=$(< ${config.sops.secrets."mcp/cloudflare-token".path})
          exec ${pkgs.nix}/bin/nix shell nixpkgs#nodejs_22 --command \
            npx -y cloudflare-mcp-pro
        '');

        servers."hetzner".command = toString (pkgs.writeShellScript "mcp-hetzner" ''
          export HETZNER_CLOUD_TOKEN=$(< ${config.sops.secrets."mcp/hetzner-token".path})
          exec ${pkgs.nix}/bin/nix shell nixpkgs#nodejs_22 --command \
            npx -y hetzner-mcp
        '');

        servers."openrouter".command = toString (pkgs.writeShellScript "mcp-openrouter" ''
          export OPENROUTER_API_KEY=$(< ${config.sops.secrets."mcp/openrouter-key".path})
          export OPENROUTER_ALLOWED_MODELS="anthropic/claude-sonnet-4-5,google/gemini-2.0-flash-001,openai/gpt-4o,qwen/qwen3.7-flash:free"
          exec ${pkgs.nix}/bin/nix shell nixpkgs#nodejs_22 --command \
            npx -y openrouter-mcp
        '');

        servers."atlassian".command = toString (pkgs.writeShellScript "mcp-atlassian" ''
          _org=$(< ${config.sops.secrets."mcp/atlassian-org".path})
          export JIRA_URL="https://$_org.atlassian.net"
          export CONFLUENCE_URL="https://$_org.atlassian.net/wiki"
          export JIRA_USERNAME=$(< ${config.sops.secrets."mcp/atlassian-user".path})
          export CONFLUENCE_USERNAME=$(< ${config.sops.secrets."mcp/atlassian-user".path})
          export JIRA_API_TOKEN=$(< ${config.sops.secrets."mcp/atlassian-token".path})
          export CONFLUENCE_API_TOKEN=$(< ${config.sops.secrets."mcp/atlassian-token".path})
          exec ${pkgs.nix}/bin/nix shell nixpkgs#uv --command uvx mcp-atlassian
        '');

        # Logs in the SP via Azure CLI before starting the server so that
        # --authentication azcli can pick up a valid token.
        servers."azure-devops".command = toString (pkgs.writeShellScript "mcp-azure-devops" ''
          export ADO_ORG=$(< ${config.sops.secrets."mcp/ado-org".path})
          export AZURE_TENANT_ID=$(< ${config.sops.secrets."mcp/azure-tenant-id".path})
          export AZURE_CLIENT_ID=$(< ${config.sops.secrets."mcp/azure-client-id".path})
          export AZURE_CLIENT_SECRET=$(< ${config.sops.secrets."mcp/azure-client-secret".path})
          exec ${pkgs.nix}/bin/nix shell nixpkgs#azure-cli nixpkgs#nodejs_22 --command \
            sh -c 'az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_CLIENT_SECRET" --tenant "$AZURE_TENANT_ID" --allow-no-subscriptions --output none && npx -y @azure-devops/mcp "$ADO_ORG" --authentication azcli'
        '');

        servers."terraform".command = toString (pkgs.writeShellScript "mcp-terraform" ''
          export TFE_TOKEN=$(< ${config.sops.secrets."mcp/terraform-token".path})
          exec ${pkgs.terraform-mcp-server}/bin/terraform-mcp-server
        '');

        # @azure/mcp is a .NET NativeAOT binary; needs ICU on NixOS.
        servers."azure".command = toString (pkgs.writeShellScript "mcp-azure" ''
          export AZURE_TENANT_ID=$(< ${config.sops.secrets."mcp/azure-tenant-id".path})
          export AZURE_CLIENT_ID=$(< ${config.sops.secrets."mcp/azure-client-id".path})
          export AZURE_CLIENT_SECRET=$(< ${config.sops.secrets."mcp/azure-client-secret".path})
          export LD_LIBRARY_PATH="${pkgs.icu}/lib"
          exec ${pkgs.nix}/bin/nix shell nixpkgs#nodejs_22 --command \
            npx -y @azure/mcp@latest server start
        '');
      };
    };
}
