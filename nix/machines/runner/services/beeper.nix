{ ... }:

{
  flake.clan.machines."runner" = { config, ... }:
    {
      virtualisation.podman.enable = true;
      virtualisation.oci-containers.backend = "podman";

      clan.core.vars.generators."beeper" = {
        share = true;
        prompts."token" = {
          description = "Beeper dev access token (Settings -> Developers)";
          type = "hidden";
          persist = true;
        };
        files."env".secret = true;
        script = ''
          printf 'BEEPER_TOKEN=' > "$out/env"
          tr -d '\n' < "$prompts/token" >> "$out/env"
        '';
      };

      virtualisation.oci-containers.containers.beeperbox = {
        image = "ghcr.io/hamr0/beeperbox:0.9.2";
        environment.MCP_ALLOWED_HOSTS = "localhost,127.0.0.1,::1";
        environmentFiles = [ config.clan.core.vars.generators."beeper".files."env".path ];
        volumes = [ "/var/lib/beeperbox:/root/.config" ];
        ports = [
          "127.0.0.1:6080:6080"
          "127.0.0.1:23373:23380"
          "127.0.0.1:23375:23375"
        ];
        extraOptions = [ "--shm-size=256m" "--security-opt=no-new-privileges:true" ];
      };

      systemd.tmpfiles.rules = [ "d /var/lib/beeperbox 0700 root root -" ];

      services.hermes-agent.mcpServers.beeper.url = "http://127.0.0.1:23375";
    };
}
