{ nixConfig, ... }:

let
  toBytesString = gb: toString (gb * 1024 * 1024 * 1024);
in
{
  flake.modules.nixos."default" = { lib, config, ... }: {
    documentation.nixos.enable = false;

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "@wheel" ];

      accept-flake-config = true;
      substituters = lib.mkBefore nixConfig.extra-substituters;
      trusted-public-keys = lib.mkBefore nixConfig.extra-trusted-public-keys;

      use-xdg-base-directories = true;
      auto-optimise-store = true;
      min-free = toBytesString 2;
    };

    sops.templates."access-tokens.conf".content = ''
      access-tokens = "github.com=${config.sops.placeholder.pat_github}"
    '';
    nix.extraOptions = "!include ${config.sops.templates."access-tokens.conf".path}";
  };
}
