{ ... }:

{
  flake.clan.machines."runner" = { config, pkgs, ... }:
    let
      httpPort = 23383;

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

      protonCal = pkgs.buildGoModule {
        pname = "proton-cal";
        version = "unstable-2026-06-25";
        src = pkgs.fetchFromGitHub {
          owner = "cheeseandcereal";
          repo = "proton-cal";
          rev = "5ff2791a0823ffbd592c3c95808819d40d4e639a";
          hash = "sha256-6AwaMtAlArriy6Xc5HOeDUvyMaqZwx/sBxAthZlmPhc=";
        };
        vendorHash = "sha256-rar5WDJkugXsLnivdvB3wCICcpiJDAC4KX0pBx/fShw=";
        subPackages = [ "cmd/proton-cal" ];
      };

      entrypoint = pkgs.writeShellScript "entrypoint" ''
        export HOME=/data
        exec ${pkgs.nodejs_24}/bin/node ${supergateway}/dist/index.js \
          --stdio "${protonCal}/bin/proton-cal mcp" \
          --outputTransport streamableHttp \
          --port ${toString httpPort}
      '';

      image = pkgs.dockerTools.buildImage {
        name = "proton-calendar-mcp";
        tag = "latest";
        copyToRoot = [
          pkgs.bash
          pkgs.cacert
          pkgs.nodejs_24
          supergateway
          protonCal
        ];
        config = {
          Entrypoint = [ "${entrypoint}" ];
          Env = [ "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt" ];
        };
      };
    in
    {
      virtualisation.oci-containers.containers.proton-calendar = {
        image = "${image.imageName}:${image.imageTag}";
        imageFile = image;
        volumes = [ "/var/lib/proton-calendar:/data" ];
        ports = [ "127.0.0.1:${toString httpPort}:${toString httpPort}" ];
        extraOptions = [ "--security-opt=no-new-privileges:true" ];
      };

      systemd.tmpfiles.rules = [ "d /var/lib/proton-calendar 0700 root root -" ];

      services.traefik.dynamicConfigOptions = {
        http.routers.proton-calendar = {
          rule = "Host(`mcp.${config.beannet.domain}`) && PathPrefix(`/proton-calendar`)";
          entryPoints = [ "websecure" ];
          service = "proton-calendar";
          middlewares = [ "mcp-auth" "mcp-stripprefix" ];
          tls.certResolver = "cloudflare";
        };
        http.services.proton-calendar.loadBalancer.servers = [
          { url = "http://127.0.0.1:${toString httpPort}"; }
        ];
      };
    };
}
