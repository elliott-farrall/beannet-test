{ ... }:

{
  flake.clan.machines."runner" = { config, pkgs, ... }:
    let
      httpPort = 23382;

      supergateway = pkgs.buildNpmPackage {
        pname = "supergateway";
        version = "4.1.0";
        src = pkgs.fetchFromGitHub {
          owner = "supercorp-ai";
          repo = "supergateway";
          rev = "a3ce8ba34c40f7565d1786e1dbd19621aca86093";
          hash = "sha256-oIO+EZ+9MFw5EmsPBDyxlfmPHJQ+7JhlH9qEep2Gv+s=";
        };
        nativeBuildInputs = [ pkgs.nodejs_24 ];
        npmDepsHash = "sha256-UxX19Sgp5sTAko/bC8+qZRpy6eCpYsxc/f3D+zuMGvs=";
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

      protonPassMcp = pkgs.buildNpmPackage {
        pname = "proton-pass-community-mcp";
        version = "0.0.0";
        src = pkgs.fetchFromGitHub {
          owner = "hesreallyhim";
          repo = "proton-pass-community-mcp";
          rev = "de1bb7ba4a20dc9495bfd6dc7f5bf987cd49cab1";
          hash = "sha256-635VESd7wJ5MU0826bDhFv4jVUj0Zekrx23kBDg4Xfg=";
        };
        nativeBuildInputs = [ pkgs.nodejs_24 ];
        npmDepsHash = "sha256-KBYqj19ynLGzmG9FBaHUPm3Xi5c1bTqSob7PEliSQsM=";
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
        export HOME=/data
        export PROTON_PASS_SESSION_DIR=/data/pass-cli
        export PASS_CLI_BIN=${pkgs.proton-pass-cli}/bin/pass-cli
        ${pkgs.proton-pass-cli}/bin/pass-cli login || true
        exec ${pkgs.nodejs_24}/bin/node ${supergateway}/dist/index.js \
          --stdio "${pkgs.nodejs_24}/bin/node ${protonPassMcp}/dist/index.js" \
          --outputTransport streamableHttp \
          --port ${toString httpPort}
      '';

      image = pkgs.dockerTools.buildImage {
        name = "proton-pass-mcp";
        tag = "latest";
        copyToRoot = [
          pkgs.bash
          pkgs.cacert
          pkgs.nodejs_24
          pkgs.proton-pass-cli
          supergateway
          protonPassMcp
        ];
        config = {
          Entrypoint = [ "${entrypoint}" ];
          Env = [ "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
        };
      };
    in
    {
      virtualisation.oci-containers.containers.proton-pass = {
        image = "${image.imageName}:${image.imageTag}";
        imageFile = image;
        environmentFiles = [ config.clan.core.vars.generators."proton".files."env".path ];
        volumes = [ "/var/lib/proton-pass-mcp:/data" ];
        ports = [ "127.0.0.1:${toString httpPort}:${toString httpPort}" ];
        extraOptions = [ "--security-opt=no-new-privileges:true" ];
      };

      systemd.tmpfiles.rules = [ "d /var/lib/proton-pass-mcp 0700 root root -" ];

      services.traefik.dynamicConfigOptions = {
        http.routers.proton-pass = {
          rule = "Host(`mcp.${config.beannet.domain}`) && PathPrefix(`/proton-pass`)";
          entryPoints = [ "websecure" ];
          service = "proton-pass";
          middlewares = [ "mcp-auth" "mcp-stripprefix" ];
          tls.certResolver = "cloudflare";
        };
        http.services.proton-pass.loadBalancer.servers = [
          { url = "http://127.0.0.1:${toString httpPort}"; }
        ];
      };
    };
}
