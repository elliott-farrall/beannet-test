{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."proton" = {
      share = true;
      prompts."username" = {
        description = "Proton account email";
        type = "text";
        persist = true;
      };
      prompts."password" = {
        description = "Proton account password";
        type = "hidden";
        persist = true;
      };
      prompts."token" = {
        description = "Proton Pass personal access token (pst_...)";
        type = "hidden";
        persist = true;
      };
      files."env".secret = true;
      script = ''
        {
          printf 'PROTON_USERNAME='
          tr -d '\n' < "$prompts/username"
          printf '\nPROTON_PASSWORD='
          tr -d '\n' < "$prompts/password"
          printf '\nPROTON_PASS_PERSONAL_ACCESS_TOKEN='
          tr -d '\n' < "$prompts/token"
          printf '\n'
        } > "$out/env"
      '';
    };
  };
}
