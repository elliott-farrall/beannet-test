{ ... }:

{
  flake.clan.machines."runner" = { config, pkgs, ... }:
    let
      httpPort = 23382;

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
          --stdio "${pkgs.mcp-nixos}/bin/mcp-nixos" \
          --outputTransport streamableHttp \
          --stateful \
          --apiKey "$COMPOSIO_TOKEN" \
          --port ${toString httpPort}
      '';

      image = pkgs.dockerTools.buildImage {
        name = "nixos-mcp";
        tag = "latest";
        copyToRoot = [
          pkgs.bash
          pkgs.cacert
          pkgs.mcp-nixos
          pkgs.nodejs_24
          supergateway
        ];
        config = {
          Entrypoint = [ "${entrypoint}" ];
          Env = [ "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
        };
      };
    in
    {
      clan.core.vars.generators."nixos" = {
        share = true;
        files."composio".secret = true;
        runtimeInputs = [ pkgs.openssl ];
        script = ''
          printf 'COMPOSIO_TOKEN=' > "$out/composio"
          openssl rand -hex 32 >> "$out/composio"
        '';
      };

      virtualisation.oci-containers.containers.nixos = {
        image = "${image.imageName}:${image.imageTag}";
        imageFile = image;
        environmentFiles = [ config.clan.core.vars.generators."nixos".files."composio".path ];
        ports = [ "127.0.0.1:${toString httpPort}:${toString httpPort}" ];
        extraOptions = [ "--security-opt=no-new-privileges:true" ];
      };

      services.traefik.dynamicConfigOptions = {
        http.routers.nixos = {
          rule = "Host(`mcp.${config.beannet.domain}`) && PathPrefix(`/nixos`)";
          entryPoints = [ "websecure" ];
          service = "nixos";
          middlewares = [ "mcp-stripprefix" ];
          tls.certResolver = "cloudflare";
        };
        http.services.nixos.loadBalancer.servers = [
          { url = "http://127.0.0.1:${toString httpPort}"; }
        ];
      };
    };
}
