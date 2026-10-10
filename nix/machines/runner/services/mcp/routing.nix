{ ... }:

{
  flake.clan.machines."runner" = { ... }:
    {
      services.traefik.dynamicConfigOptions.http.middlewares.mcp-stripprefix.replacePathRegex = {
        regex = "^/[^/]+/?(.*)$";
        replacement = "/$1";
      };
    };
}
