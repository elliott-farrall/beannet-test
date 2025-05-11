{ nixConfig, ... }:

let
  toBytesString = gb: toString (gb * 1024 * 1024 * 1024);
in
{
  flake.modules.nixos."default" = { lib, config, ... }: {
    documentation.nixos.enable = false;

    nix = {
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users = [ "@wheel" ];

        accept-flake-config = true;
        substituters = lib.mkBefore nixConfig.extra-substituters;
        trusted-public-keys = lib.mkBefore nixConfig.extra-trusted-public-keys;

        use-xdg-base-directories = true;
        auto-optimise-store = true;
        min-free = toBytesString 2;
      };
      extraOptions = "!include ${config.clan.core.vars.generators."github".files."access-tokens.conf".path}";
    };

    clan.core.vars.generators."github" = {
      share = true;

      files."access-tokens.conf" = { };

      prompts."pat" = {
        description = "GitHub personal access token";
        type = "hidden";
        persist = true;
      };

      script = ''
        cat <<EOF > $out/access-tokens.conf
        access-tokens = "github.com=$(cat $prompts/pat)"
        EOF
      '';
    };
  };
}
