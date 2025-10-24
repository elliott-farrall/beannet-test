{ ... }:

{
  flake.modules.nixos.default = { lib, ... }: {
    clan.core.settings.state-version.enable = lib.mkDefault true;
  };

  flake.modules.homeManager.default = { nixosConfig, ... }: {
    home = { inherit (nixosConfig.system) stateVersion; };
  };
}
