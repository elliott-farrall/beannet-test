{ ... }:

{
  flake.modules.nixos.default = { pkgs, ... }: {
    clan.core.vars.generators."hermes-api-key" = {
      share = true;
      files."env".secret = true;
      script = ''
        printf 'API_SERVER_KEY=' > "$out/env"
        ${pkgs.openssl}/bin/openssl rand -hex 32 >> "$out/env"
      '';
    };
  };
}
