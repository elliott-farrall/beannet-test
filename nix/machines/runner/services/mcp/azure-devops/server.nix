{ ... }:

{
  flake.modules.nixos.default = { pkgs, ... }:
    {
      clan.core.vars.generators."azure-devops" = {
        share = true;

        prompts."organisation" = {
          description = "Azure DevOps organisation name (e.g. my-org)";
          type = "line";
          persist = true;
        };

        files."env".secret = true;
        files."composio".secret = true;
        runtimeInputs = [ pkgs.openssl ];
        script = ''
          printf 'ADO_ORG=' > "$out/env"
          tr -d '\n' < "$prompts/organisation" >> "$out/env"
          printf '\n' >> "$out/env"
          printf 'COMPOSIO_TOKEN=' > "$out/composio"
          openssl rand -hex 32 >> "$out/composio"
        '';
      };
    };

  flake.clan.machines."runner" = { config, pkgs, ... }:
    let
      httpPort = 23386;

      supergateway = pkgs.buildNpmPackage {
        pname = "supergateway";
        version = "4.2.0-rc.1";
        src = pkgs.fetchFromGitHub {
          owner = "supercorp-ai";
          repo = "supergateway";
          rev = "dc9066fa1ea3d9bc8f65f38a5be5d0bbd1085f4b";
          hash = "sha256-P5RPgssyqarvGdgYPaEmGxrC0jZPpOxSCeT4Jif/X9I=";
        };
        nativeBuildInputs = [ pkgs.nodejs_24 ];
        npmDepsHash = "sha256-ix1WNLU3QaTn0uAGXei4RDdpEhe6bx5OtDZhZBYVUcc=";
        buildPhase = ''
          runHook preBuild
          npm run build
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r . $out
          runHook postInstall
        '';
      };

      azureDevopsMcp = pkgs.buildNpmPackage {
        pname = "azure-devops-mcp";
        version = "2.10.0";
        src = pkgs.fetchFromGitHub {
          owner = "microsoft";
          repo = "azure-devops-mcp";
          rev = "43a2b179b02d912399be612e0f7b5121a55eb692";
          hash = "sha256-So/zsCt8uLAOjdk0OdgB6ENe9x2mmMy8YM4V/xlG+6c=";
        };
        nativeBuildInputs = [ pkgs.nodejs_24 pkgs.pkg-config pkgs.python3 ];
        buildInputs = [ pkgs.libsecret ];
        npmDepsHash = "sha256-ZWWiPIVovkSDJNhih/neXuUlDJcMK21xk1P4j6uGNYY=";
        buildPhase = ''
          runHook preBuild
          npm run build
          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out
          cp -r . $out
          runHook postInstall
        '';
      };

      stdioCmd = pkgs.writeShellScript "ado-mcp-stdio" ''
        exec ${pkgs.nodejs_24}/bin/node ${azureDevopsMcp}/dist/index.js "$ADO_ORG" --authentication env
      '';

      entrypoint = pkgs.writeShellScript "entrypoint" ''
        exec ${pkgs.nodejs_24}/bin/node ${supergateway}/dist/index.js \
          --stdio "${stdioCmd}" \
          --outputTransport streamableHttp \
          --stateful \
          --apiKey "$COMPOSIO_TOKEN" \
          --port ${toString httpPort}
      '';

      image = pkgs.dockerTools.buildImage {
        name = "azure-devops-mcp";
        tag = "latest";
        copyToRoot = [
          pkgs.bash
          pkgs.cacert
          pkgs.nodejs_24
          azureDevopsMcp
          supergateway
        ];
        config = {
          Entrypoint = [ "${entrypoint}" ];
          Env = [ "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
        };
      };
    in
    {
      virtualisation.oci-containers.containers.azure-devops = {
        image = "${image.imageName}:${image.imageTag}";
        imageFile = image;
        environmentFiles = [
          config.clan.core.vars.generators."azure".files."env".path
          config.clan.core.vars.generators."azure-devops".files."env".path
          config.clan.core.vars.generators."azure-devops".files."composio".path
        ];
        ports = [ "127.0.0.1:${toString httpPort}:${toString httpPort}" ];
        extraOptions = [ "--security-opt=no-new-privileges:true" ];
      };

      services.traefik.dynamicConfigOptions = {
        http.routers.azure-devops = {
          rule = "Host(`mcp.${config.beannet.domain}`) && PathPrefix(`/azure-devops`)";
          entryPoints = [ "websecure" ];
          service = "azure-devops";
          middlewares = [ "mcp-stripprefix" ];
          tls.certResolver = "cloudflare";
        };
        http.services.azure-devops.loadBalancer.servers = [
          { url = "http://127.0.0.1:${toString httpPort}"; }
        ];
      };
    };
}
