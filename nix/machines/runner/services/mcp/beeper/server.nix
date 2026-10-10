{ ... }:

{
  flake.clan.machines."runner" = { config, pkgs, ... }:
    {
      clan.core.vars.generators."beeper" = {
        share = true;
        prompts."token" = {
          description = "Beeper dev access token (Settings -> Developers)";
          type = "hidden";
          persist = true;
        };
        files."env".secret = true;
        runtimeInputs = [ pkgs.openssl ];
        script = ''
          printf 'BEEPER_TOKEN=' > "$out/env"
          tr -d '\n' < "$prompts/token" >> "$out/env"
          printf '\nMCP_AUTH_TOKEN=' >> "$out/env"
          openssl rand -hex 32 >> "$out/env"
        '';
      };

      virtualisation.oci-containers.containers.beeperbox = {
        image = "ghcr.io/hamr0/beeperbox:0.9.2";
        environment.MCP_ALLOWED_HOSTS = "localhost,127.0.0.1,mcp.${config.beannet.domain}";
        environmentFiles = [
          config.clan.core.vars.generators."beeper".files."env".path
        ];
        volumes = [ "/var/lib/beeperbox:/root/.config" ];
        ports = [
          "127.0.0.1:6080:6080"
          "127.0.0.1:23375:23375"
        ];
        extraOptions = [ "--shm-size=256m" "--security-opt=no-new-privileges:true" ];
      };

      systemd.tmpfiles.rules = [ "d /var/lib/beeperbox 0700 root root -" ];

      services.traefik.dynamicConfigOptions = {
        http.routers.beeper = {
          rule = "Host(`mcp.${config.beannet.domain}`) && PathPrefix(`/beeper`)";
          entryPoints = [ "websecure" ];
          service = "beeper";
          middlewares = [ "mcp-stripprefix" "mcp-rootpath" ];
          tls.certResolver = "cloudflare";
        };
        http.services.beeper.loadBalancer.servers = [
          { url = "http://127.0.0.1:23375"; }
        ];
      };
    };
}
