{ ... }:

{
  flake.clan.machines."runner" = { pkgs, ... }:
    {
      _module.args.mcpPackages = {
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
      };

      virtualisation.podman.enable = true;
      virtualisation.oci-containers.backend = "podman";
    };
}
