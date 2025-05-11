{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    clan.core.settings.state-version.enable = true;
  };

  flake.modules.homeManager."default" = { nixosConfig, ... }: {
    home = { inherit (nixosConfig.system) stateVersion; };
  };
}
