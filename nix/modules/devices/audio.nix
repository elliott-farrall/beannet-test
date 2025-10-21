{ ... }:

{
  flake.modules.nixos."devices/audio" = { ... }: {
    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
    };
  };
}
