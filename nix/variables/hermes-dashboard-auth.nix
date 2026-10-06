{ ... }:

{
  flake.modules.nixos.default = { pkgs, ... }: {
    clan.core.vars.generators."hermes-dashboard-auth" = {
      share = true;
      files."env".secret = true;
      script = ''
        ${pkgs.openssl}/bin/openssl rand -hex 32 > "$out/dashboard-secret"
        ${pkgs.openssl}/bin/openssl rand -hex 32 > "$out/dashboard-password"
        {
          printf 'HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin\n'
          printf 'HERMES_DASHBOARD_BASIC_AUTH_PASSWORD='
          tr -d '\n' < "$out/dashboard-password"
          printf '\nHERMES_DASHBOARD_BASIC_AUTH_SECRET='
          tr -d '\n' < "$out/dashboard-secret"
          printf '\n'
        } > "$out/env"
      '';
    };
  };
}
