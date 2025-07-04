rec {
  inputs = {

    /* -------------------------------------------------------------------------- */
    /*                                  Framework                                 */
    /* -------------------------------------------------------------------------- */

    systems = {
      url = "github:nix-systems/x86_64-linux";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "dep_nixpkgs-lib";
    };
    clan-core = {
      url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
      # TODO - Manage dependencies for clan-core
    };
    import-tree = {
      url = "github:vic/import-tree";
    };
    make-shell = {
      url = "github:nicknovitski/make-shell";
      inputs.flake-compat.follows = "dep_flake-compat";
    };


    /* -------------------------------------------------------------------------- */
    /*                                   Modules                                  */
    /* -------------------------------------------------------------------------- */

    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # impermanence = {
    #   url = "github:nix-community/impermanence";
    # };
    preservation = {
      url = "github:nix-community/preservation";
    };
    chaotic = {
      url = "github:chaotic-cx/nyx";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      # TODO - Manage dependencies for chaotic
    };

    /* -------------------------------------------------------------------------- */
    /*                                     CI                                     */
    /* -------------------------------------------------------------------------- */

    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.flake-compat.follows = "dep_flake-compat";
      inputs.gitignore.follows = "dep_gitignore";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixago = {
      url = "github:jmgilman/nixago";
      # TODO - Manage dependencies for nixago
    };

    /* -------------------------------------------------------------------------- */
    /*                                    Theme                                   */
    /* -------------------------------------------------------------------------- */

    stylix = {
      url = "github:danth/stylix";
      inputs.base16.follows = "dep_base16";
      inputs.base16-fish.follows = "dep_base16-fish";
      inputs.base16-helix.follows = "dep_base16-helix";
      inputs.base16-vim.follows = "dep_base16-vim";
      inputs.firefox-gnome-theme.follows = "dep_firefox-gnome-theme";
      inputs.flake-compat.follows = "dep_flake-compat";
      inputs.flake-utils.follows = "dep_flake-utils";
      inputs.git-hooks.follows = "git-hooks-nix";
      inputs.gnome-shell.follows = "dep_gnome-shell";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nur.follows = "dep_nur";
      inputs.systems.follows = "systems";
      inputs.tinted-foot.follows = "dep_tinted-foot";
      inputs.tinted-kitty.follows = "dep_tinted-kitty";
      inputs.tinted-schemes.follows = "dep_tinted-schemes";
      inputs.tinted-tmux.follows = "dep_tinted-tmux";
      inputs.tinted-zed.follows = "dep_tinted-zed";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    /* -------------------------------------------------------------------------- */
    /*                                    Tools                                   */
    /* -------------------------------------------------------------------------- */

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    /* -------------------------------------------------------------------------- */
    /*                                  Packages                                  */
    /* -------------------------------------------------------------------------- */

    code-insiders = {
      url = "github:iosmanthus/code-insiders-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    clan-cli = {
      url = "https://git.clan.lol/clan/clan-core/archive/050804a917505d63d3edf2757ff7105383d47ae5.tar.gz";
      # TODO - Can be removed when https://git.clan.lol/clan/clan-core/issues/3751 is resolved
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.flake-utils.follows = "dep_flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "dep_rust-overlay";
      inputs.systems.follows = "systems";
    };

    /* -------------------------------------------------------------------------- */
    /*                                Dependencies                                */
    /* -------------------------------------------------------------------------- */

    dep_base16 = {
      url = "github:SenchoPens/base16.nix";
      inputs.fromYaml.follows = "dep_fromYaml";
    };
    dep_base16-fish = {
      url = "github:tomyun/base16-fish";
      flake = false;
    };
    dep_base16-helix = {
      url = "github:tinted-theming/base16-helix";
      flake = false;
    };
    dep_base16-vim = {
      url = "github:tinted-theming/base16-vim";
      flake = false;
    };
    dep_fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dep_firefox-gnome-theme = {
      url = "github:rafaelmardojai/firefox-gnome-theme";
      flake = false;
    };
    dep_flake-compat = {
      url = "github:edolstra/flake-compat";
    };
    dep_flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    dep_fromYaml = {
      url = "github:SenchoPens/fromYaml";
      flake = false;
    };
    dep_gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dep_gnome-shell = {
      url = "github:GNOME/gnome-shell";
      flake = false;
    };
    dep_jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dep_nixpkgs-lib = {
      url = "github:nix-community/nixpkgs.lib";
    };
    dep_nur = {
      url = "github:nix-community/NUR";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    dep_rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dep_tinted-foot = {
      url = "github:tinted-theming/tinted-foot";
      flake = false;
    };
    dep_tinted-kitty = {
      url = "github:tinted-theming/tinted-kitty";
      flake = false;
    };
    dep_tinted-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    dep_tinted-tmux = {
      url = "github:tinted-theming/tinted-tmux";
      flake = false;
    };
    dep_tinted-zed = {
      url = "github:tinted-theming/base16-zed";
      flake = false;
    };

  };

  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs: with inputs.nixpkgs.lib; inputs.flake-parts.lib.mkFlake
    {
      inputs = filterAttrs (name: _value: ! hasPrefix "dep_" name) inputs;
      specialArgs = { inherit nixConfig; };
    }
    (inputs.import-tree ./nix);
}
