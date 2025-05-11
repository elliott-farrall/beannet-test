{ config, ... }:

{
  flake.modules.nixos."shell/zsh" = { ... }: {
    home-manager.sharedModules = with config.flake.modules; [ homeManager."shell/bash" ];
  };

  flake.modules.homeManager."shell/bash" = { ... }: {
    programs.bash.enable = true;
  };
}
