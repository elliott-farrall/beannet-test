{ ... }:

{
  flake.clan.machines."runner" = { config, pkgs, ... }:
    let
      authPort = 23381;

      mcpAuthVerifier = pkgs.writeText "mcp-auth.py" ''
        import os
        import re
        from http.server import BaseHTTPRequestHandler, HTTPServer

        def token_for(path):
            segments = [s for s in path.split("/") if s]
            if not segments:
                return None
            var = "TOKEN_" + re.sub(r"[^A-Z0-9]", "_", segments[0].upper())
            return os.environ.get(var)

        class Handler(BaseHTTPRequestHandler):
            def do_GET(self):
                token = token_for(self.headers.get("X-Forwarded-Uri", ""))
                if token and self.headers.get("Authorization") == "Bearer " + token:
                    self.send_response(204)
                else:
                    self.send_response(401)
                self.end_headers()

            def log_message(self, *args):
                pass

        HTTPServer(("127.0.0.1", ${toString authPort}), Handler).serve_forever()
      '';
    in
    {
      services.traefik.dynamicConfigOptions.http.middlewares = {
        mcp-stripprefix.replacePathRegex = {
          regex = "^/[^/]+/?(.*)$";
          replacement = "/$1";
        };
        mcp-auth.forwardAuth = {
          address = "http://127.0.0.1:${toString authPort}";
          trustForwardHeader = true;
        };
      };

      clan.core.vars.generators."mcp-auth" = {
        files."env".secret = true;
        runtimeInputs = [ pkgs.openssl ];
        script = ''
          : > "$out/env"
          for name in nixos hetzner terraform azure; do
            var="TOKEN_$(printf '%s' "$name" | tr 'a-z-' 'A-Z_')"
            printf '%s=' "$var" >> "$out/env"
            openssl rand -hex 32 >> "$out/env"
          done
        '';
      };

      systemd.services.mcp-auth = {
        description = "Bearer-token verifier for MCP endpoints (Traefik forwardAuth)";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          EnvironmentFile = [ config.clan.core.vars.generators."mcp-auth".files."env".path ];
          ExecStart = "${pkgs.python3}/bin/python3 ${mcpAuthVerifier}";
          Restart = "always";
        };
      };
    };
}
