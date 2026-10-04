{ ... }:

{
  flake.modules.nixos.default = { pkgs, ... }: {
    users.defaultUserShell = pkgs.zsh;

    programs.zsh.enable = true;
    environment.pathsToLink = [ "/share/zsh" ]; # Allows completion for system packages
  };

  flake.modules.homeManager.default = { config, ... }: {
    programs.bash.enable = true;

    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      dotDir = "${config.home.homeDirectory}/.config/zsh";
    };

    home.persistence.state.directories = [ ".config/zsh" ];
  };
}
