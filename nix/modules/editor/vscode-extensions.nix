{ inputs, ... }:

let
  module = { pkgs, ... }: {
    programs.vscode.profiles.default.extensions = (pkgs.nix4vscode.forVscode [
      "github.copilot"
      "github.copilot-chat"
    ]) ++ (with pkgs.vscode-marketplace; [
      # Core
      ms-vscode.remote-explorer
      ms-vscode.remote-server
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode-remote.remote-containers
      ms-vscode.remote-repositories
      ms-vscode.azure-repos
      ms-azuretools.vscode-docker
      ms-azuretools.vscode-azureterraform
      ms-kubernetes-tools.vscode-kubernetes-tools
      github.vscode-github-actions
      hashicorp.terraform
      # Environment
      henriquebruno.github-repository-manager
      mhutchie.git-graph
      mkhl.direnv
      # Editor
      vivaxy.vscode-conventional-commits
      exodiusstudios.comment-anchors
      stackbreak.comment-divider
      bierner.markdown-preview-github-styles
      bierner.markdown-checkbox
      bierner.markdown-emoji
      njpwerner.autodocstring
      # Languages
      jnoortheen.nix-ide # Nix
      redhat.vscode-yaml # YAML
      tamasfe.even-better-toml # TOML
      samuelcolvin.jinjahtml # Jinja
      ms-python.python # Python
    ]);
  };
in
{
  flake.modules.nixos."default" = { ... }: {
    nixpkgs.overlays = with inputs; [
      nix-vscode-extensions.overlays.default
      nix4vscode.overlays.forVscode
    ];
  };

  flake.modules.homeManager."editor/vscode" = module;
  flake.modules.homeManager."editor/vscode-insiders" = module;
}
