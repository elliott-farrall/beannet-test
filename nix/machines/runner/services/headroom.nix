{ ... }:

{
  flake.clan.machines."runner" = { config, ... }:
    {
      virtualisation.oci-containers.containers.headroom = {
        image = "ghcr.io/headroomlabs-ai/headroom@sha256:1ea5e053e3da346f1b2d66af9c3809faa9d99ccb2fae447a7ffe5aae96783a8a";
        cmd = [
          "--host"
          "0.0.0.0"
          "--port"
          "8787"
          "--backend"
          "openrouter"
        ];
        ports = [ "127.0.0.1:8787:8787" ];
        environment = {
          HEADROOM_ALLOW_UNAUTHENTICATED_BIND = "1";
        };
        environmentFiles = [ config.clan.core.vars.generators."openrouter".files."env".path ];
      };

      systemd.services.openclaw-gateway = {
        after = [ "podman-headroom.service" ];
        wants = [ "podman-headroom.service" ];
      };
    };
}
