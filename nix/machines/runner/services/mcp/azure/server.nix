{ ... }:

{
  flake.clan.machines."runner" = { config, lib, pkgs, ... }:
    let
      httpPort = 23385;

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

      entrypoint = pkgs.writeShellScript "entrypoint" ''
        exec ${pkgs.nodejs_24}/bin/node ${supergateway}/dist/index.js \
          --stdio "${pkgs.azure-mcp}/bin/azure-mcp server start" \
          --outputTransport streamableHttp \
          --stateful \
          --apiKey "$COMPOSIO_TOKEN" \
          --port ${toString httpPort}
      '';

      image = pkgs.dockerTools.buildImage {
        name = "azure-mcp";
        tag = "latest";
        copyToRoot = [
          pkgs.bash
          pkgs.cacert
          pkgs.nodejs_24
          pkgs.azure-mcp
          pkgs.icu
          pkgs.openssl
          supergateway
        ];
        config = {
          Entrypoint = [ "${entrypoint}" ];
          Env = [
            "HOME=/tmp"
            "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            "LD_LIBRARY_PATH=${lib.makeLibraryPath [pkgs.icu pkgs.openssl]}"
          ];
        };
      };
    in
    {
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
        files."composio".secret = true;
        runtimeInputs = [ pkgs.openssl ];
        script = ''
          {
            printf 'AZURE_TENANT_ID='; tr -d '\n' < "$prompts/tenant-id"; printf '\n'
            printf 'AZURE_CLIENT_ID='; tr -d '\n' < "$prompts/client-id"; printf '\n'
            printf 'AZURE_CLIENT_SECRET='; tr -d '\n' < "$prompts/client-secret"; printf '\n'
          } > "$out/env"
          printf 'COMPOSIO_TOKEN=' > "$out/composio"
          openssl rand -hex 32 >> "$out/composio"
        '';
      };

      virtualisation.oci-containers.containers.azure = {
        image = "${image.imageName}:${image.imageTag}";
        imageFile = image;
        environmentFiles = [
          config.clan.core.vars.generators."azure".files."env".path
          config.clan.core.vars.generators."azure".files."composio".path
        ];
        ports = [ "127.0.0.1:${toString httpPort}:${toString httpPort}" ];
        extraOptions = [ "--security-opt=no-new-privileges:true" ];
      };

      services.traefik.dynamicConfigOptions = {
        http.routers.azure = {
          rule = "Host(`mcp.${config.beannet.domain}`) && PathPrefix(`/azure`)";
          entryPoints = [ "websecure" ];
          service = "azure";
          middlewares = [ "mcp-stripprefix" "mcp-rootpath" ];
          tls.certResolver = "cloudflare";
        };
        http.services.azure.loadBalancer.servers = [
          { url = "http://127.0.0.1:${toString httpPort}"; }
        ];
      };
    };
}
