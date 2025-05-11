{ inputs, ... }:

{
  flake.modules.nixos."shared" = { ... }: {
    imports = with inputs; [ clan-core.clanModules.state-version ];
  };

  flake.modules.homeManager."shared" = { nixosConfig, ... }: {
    home = { inherit (nixosConfig.system) stateVersion; };
  };
}
