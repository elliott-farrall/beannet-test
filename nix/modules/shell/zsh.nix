{ config, ... }:

let
  inherit (config.flake) modules;
in
{
  flake.modules.nixos.default = { lib, ... }: {
    imports = with modules.nixos; [ shell-zsh ];

    options = {
      shell.zsh.enable = lib.mkEnableOption "zsh";
    };
  };

  flake.modules.nixos.shell-zsh = { lib, pkgs, config, ... }: {
    config = lib.mkIf config.shell.zsh.enable {
      home-manager.sharedModules = with modules.homeManager; [ shell-zsh ];

      users.defaultUserShell = pkgs.zsh;

      programs.zsh.enable = true;
      environment.pathsToLink = [ "/share/zsh" ]; # Allows completion for system packages
    };
  };

  flake.modules.homeManager.shell-zsh = { ... }: {
    config = {
      programs.zsh = {
        enable = true;
        syntaxHighlighting.enable = true;
      };
    };
  };
}
