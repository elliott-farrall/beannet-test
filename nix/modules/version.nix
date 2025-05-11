{ inputs, ... }:

{
  flake.modules.nixos."default" = { ... }: {
    imports = with inputs; [ clan-core.clanModules.state-version ];
  };

  flake.modules.homeManager."default" = { nixosConfig, ... }: {
    home = { inherit (nixosConfig.system) stateVersion; };
  };
}
