{ ... }:

{
  flake.clan.machines."runner" = { config, pkgs, ... }:
    let
      httpPort = 23384;

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
          --stdio "${pkgs.terraform-mcp-server}/bin/terraform-mcp-server" \
          --outputTransport streamableHttp \
          --stateful \
          --apiKey "$COMPOSIO_TOKEN" \
          --port ${toString httpPort}
      '';

      image = pkgs.dockerTools.buildImage {
        name = "terraform-mcp";
        tag = "latest";
        copyToRoot = [
          pkgs.bash
          pkgs.cacert
          pkgs.nodejs_24
          pkgs.terraform-mcp-server
          supergateway
        ];
        config = {
          Entrypoint = [ "${entrypoint}" ];
          Env = [ "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
        };
      };
    in
    {
      clan.core.vars.generators."terraform" = {
        share = true;
        prompts."mcp" = {
          description = "Terraform Cloud / Enterprise token";
          type = "hidden";
          persist = true;
        };
        files."env".secret = true;
        files."composio".secret = true;
        runtimeInputs = [ pkgs.openssl ];
        script = ''
          printf 'TFE_TOKEN=' > "$out/env"
          tr -d '\n' < "$prompts/mcp" >> "$out/env"
          printf '\n' >> "$out/env"
          printf 'COMPOSIO_TOKEN=' > "$out/composio"
          openssl rand -hex 32 >> "$out/composio"
        '';
      };

      virtualisation.oci-containers.containers.terraform = {
        image = "${image.imageName}:${image.imageTag}";
        imageFile = image;
        environmentFiles = [
          config.clan.core.vars.generators."terraform".files."env".path
          config.clan.core.vars.generators."terraform".files."composio".path
        ];
        ports = [ "127.0.0.1:${toString httpPort}:${toString httpPort}" ];
        extraOptions = [ "--security-opt=no-new-privileges:true" ];
      };

      services.traefik.dynamicConfigOptions = {
        http.routers.terraform = {
          rule = "Host(`mcp.${config.beannet.domain}`) && PathPrefix(`/terraform`)";
          entryPoints = [ "websecure" ];
          service = "terraform";
          middlewares = [ "mcp-stripprefix" "mcp-rootpath" ];
          tls.certResolver = "cloudflare";
        };
        http.services.terraform.loadBalancer.servers = [
          { url = "http://127.0.0.1:${toString httpPort}"; }
        ];
      };
    };
}
