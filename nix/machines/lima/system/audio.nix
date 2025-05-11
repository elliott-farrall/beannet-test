{ ... }:

{
  flake.clan.machines."lima" = { ... }: {
    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
    };
  };
}
