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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree = {
      url = "github:vic/import-tree";
    };
    make-shell = {
      url = "github:nicknovitski/make-shell";
      inputs.flake-compat.follows = "dep_flake-compat";
    };
    terranix = {
      url = "github:terranix/terranix";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
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
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.flake-compat.follows = "dep_flake-compat";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-schemas = {
      url = "github:DeterminateSystems/flake-schemas";
    };
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    vpn-confinement = {
      url = "github:Maroka-chan/VPN-Confinement";
    };
    chaotic = {
      url = "github:chaotic-cx/nyx";
      inputs.flake-schemas.follows = "flake-schemas";
      inputs.home-manager.follows = "home-manager";
      inputs.jovian.follows = "dep_jovian";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils = {
      url = "github:elliott-farrall/utils.nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
      inputs.flake-parts.follows = "flake-parts";
      inputs.gnome-shell.follows = "dep_gnome-shell";
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
    wallpapers = {
      url = "github:zhichaoh/catppuccin-wallpapers";
      flake = false;
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
    nix-schemas = {
      url = "github:DeterminateSystems/nix-src/flake-schemas";
      # TODO - Override nix package and configure dependencies
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
      inputs.nix-github-actions.follows = "dep_nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dep_nix-github-actions = {
      url = "github:zhaofengli/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dep_nixpkgs-lib = {
      url = "github:nix-community/nixpkgs.lib";
    };
    dep_nur = {
      url = "github:nix-community/NUR";
      inputs.flake-parts.follows = "flake-parts";
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
