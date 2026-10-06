{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    clan.core.vars.generators."openrouter" = {
      share = true;
      prompts."api-key" = {
        description = "OpenRouter API key (starts with sk-or-...)";
        type = "hidden";
        persist = true;
      };
      files."env".secret = true;
      script = ''
        printf 'OPENROUTER_API_KEY=' > "$out/env"
        tr -d '\n' < "$prompts/api-key" >> "$out/env"
      '';
    };
  };
}
