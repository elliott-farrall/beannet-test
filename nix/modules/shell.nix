{ ... }:

{
  flake.modules.nixos.default = { pkgs, ... }: {
    users.defaultUserShell = pkgs.zsh;

    programs.zsh.enable = true;
    environment.pathsToLink = [ "/share/zsh" ]; # Allows completion for system packages
  };

  flake.modules.homeManager.default = { ... }: {
    programs.bash.enable = true;

    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      dotDir = ".config/zsh";
    };

    home.persistence.state.directories = [ ".config/zsh" ];
  };
}
