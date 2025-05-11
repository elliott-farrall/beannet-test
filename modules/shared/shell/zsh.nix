{ config, ... }:

{
  flake.modules.nixos."shells/zsh" = { pkgs, ... }: {
    home-manager.sharedModules = with config.flake.modules; [ homeManager."shells/zsh" ];

    users.defaultUserShell = pkgs.zsh;

    programs.zsh.enable = true;
    environment.pathsToLink = [ "/share/zsh" ]; # Allows completion for system packages
  };

  flake.modules.homeManager."shells/zsh" = { ... }: {
    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
    };
  };
}
