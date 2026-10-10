{ ... }:

{
  flake.modules.homeManager.default = { config, lib, pkgs, ... }:
    let
      mcp-compressor = pkgs.python3Packages.buildPythonPackage {
        pname = "mcp-compressor";
        version = "0.33.0";
        format = "wheel";

        src = pkgs.python3Packages.fetchPypi {
          pname = "mcp_compressor";
          version = "0.33.0";
          format = "wheel";
          dist = "cp311";
          python = "cp311";
          abi = "abi3";
          platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
          hash = "sha256-1JZUK4eGIKbSwTDhHdYObuoV7/39slfagDHnfVAC2KI=";
        };

        dontCheckRuntimeDeps = true;
        pythonImportsCheck = [ "mcp_compressor" ];

        meta = {
          description = "MCP proxy that compresses upstream tool catalogues to reduce token usage";
          homepage = "https://github.com/atlassian-labs/mcp-compressor";
          license = lib.licenses.asl20;
          mainProgram = "mcp-compressor";
          platforms = [ "x86_64-linux" ];
        };
      };

      # `env` values are emitted verbatim into the wrapper, so callers must
      # quote literals themselves. This allows shell expressions such as
      # `$(cat /run/secrets/foo)` to be evaluated at runtime.
      mkCompressedMcp = { name, backend, compression ? "medium", timeout ? 60, env ? { }, headers ? { } }:
        pkgs.writeShellScriptBin "mcp-${name}" ''
          export PATH=${lib.makeBinPath [ mcp-compressor ]}:$PATH
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}=${v}") env)}
          exec mcp-compressor \
            --compression ${compression} \
            --server-name ${name} \
            -- ${lib.escapeShellArgs backend} \
            ${lib.concatStringsSep " " (lib.mapAttrsToList (k: v: "-H ${lib.escapeShellArg "${k}=${v}"}") headers)} \
            -t ${toString timeout}
        '';

      servers = {
        azure-devops = mkCompressedMcp {
          name = "azure-devops";
          backend = [
            "${pkgs.nix}/bin/nix"
            "shell"
            "nixpkgs#azure-cli"
            "nixpkgs#nodejs_22"
            "--command"
            "sh"
            "-c"
            "az login --service-principal -u \"$AZURE_CLIENT_ID\" -p \"$AZURE_CLIENT_SECRET\" --tenant \"$AZURE_TENANT_ID\" --allow-no-subscriptions --output none && npx -y @azure-devops/mcp \"$ADO_ORG\" --authentication azcli"
          ];
          env.LD_LIBRARY_PATH = lib.escapeShellArg (lib.makeLibraryPath [ pkgs.libsecret pkgs.glib ]);
        };
      };
    in
    {
      programs.mcp = {
        enable = true;

        servers."azure-devops" = {
          command = "${servers.azure-devops}/bin/mcp-azure-devops";
          env = {
            ADO_ORG.file = config.sops.secrets."mcp/ado-org".path;
            AZURE_TENANT_ID.file = config.sops.secrets."mcp/azure-tenant-id".path;
            AZURE_CLIENT_ID.file = config.sops.secrets."mcp/azure-client-id".path;
            AZURE_CLIENT_SECRET.file = config.sops.secrets."mcp/azure-client-secret".path;
          };
        };
        servers."composio" = {
          url = "https://connect.composio.dev/mcp";
          headers."x-consumer-api-key" = "{env:COMPOSIO_API_KEY}";
        };
      };

      home.persistence.state.directories = [
        ".config/mcp-compressor"
      ];
    };
}
