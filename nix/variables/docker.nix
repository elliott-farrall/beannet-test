{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."docker" = {
      share = true;
      prompts."username" = {
        description = "Docker Hub username";
        persist = true;
      };
      prompts."password" = {
        description = "Docker Hub password or access token";
        type = "hidden";
        persist = true;
      };
    };
  };
}
