{ config, ... }:

{
  flake.modules.nixos."shells/bash" = { ... }: {
    home-manager.sharedModules = with config.flake.modules; [ homeManager."shells/bash" ];
  };

  flake.modules.homeManager."shells/bash" = { ... }: {
    programs.bash.enable = true;
  };
}
