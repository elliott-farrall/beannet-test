{ ... }:

{
  flake.clan.machines."lima" = { ... }: {
    services.printing.enable = true;
    services.colord.enable = true;
  };
}
