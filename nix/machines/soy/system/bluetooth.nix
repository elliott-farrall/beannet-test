{ ... }:

{
  flake.clan.machines."soy" = { ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
