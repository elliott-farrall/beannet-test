{ config, ... }:

{
  flake.modules.nixos."shell/zsh" = { pkgs, ... }: {
    home-manager.sharedModules = with config.flake.modules; [ homeManager."shell/zsh" ];

    users.defaultUserShell = pkgs.zsh;

    programs.zsh.enable = true;
    environment.pathsToLink = [ "/share/zsh" ]; # Allows completion for system packages
  };

  flake.modules.homeManager."shell/zsh" = { ... }: {
    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
    };
  };
}
