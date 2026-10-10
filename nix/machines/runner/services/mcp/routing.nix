{ ... }:

{
  flake.clan.machines."runner" = { ... }:
    {
      services.traefik.dynamicConfigOptions.http.middlewares = {
        mcp-stripprefix.replacePathRegex = {
          regex = "^/[^/]+/?(.*)$";
          replacement = "/$1";
        };
        mcp-rootpath.replacePathRegex = {
          regex = "^/$";
          replacement = "/mcp";
        };
      };
    };
}
