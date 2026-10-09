{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."proton" = {
      share = true;
      prompts."pat" = {
        description = "Proton Pass personal access token (pst_...)";
        type = "hidden";
        persist = true;
      };
      files."env".secret = true;
      script = ''
        printf 'PROTON_PASS_PERSONAL_ACCESS_TOKEN=' > "$out/env"
        tr -d '\n' < "$prompts/pat" >> "$out/env"
      '';
    };
  };
}
