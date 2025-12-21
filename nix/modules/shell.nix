{ ... }:

{
  flake.modules.nixos.default = { pkgs, ... }: {
    users.defaultUserShell = pkgs.zsh;

    programs.zsh.enable = true;
    environment.pathsToLink = [ "/share/zsh" ]; # Allows completion for system packages
    system.userActivationScripts.zshrc = "touch .zshrc"; # Prevents initial dialogue
  };

  flake.modules.homeManager.default = { ... }: {
    programs.bash.enable = true;

    programs.zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
    };

    home.persistence.state.files = [ ".zsh_history" ];
  };
}
