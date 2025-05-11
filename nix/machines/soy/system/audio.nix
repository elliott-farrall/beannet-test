{ ... }:

{
  flake.clan.machines."soy" = { ... }: {
    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
    };
  };
}
