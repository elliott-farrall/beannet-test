{ config, ... }:

{
  flake.modules.nixos."machines/_workstation" = { ... }: {
    imports = with config.flake.modules; [
      nixos."default"
      nixos."shell/zsh"
      nixos."users/elliott"
    ];

    /* ---------------------------------- Audio --------------------------------- */

    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
    };

    /* -------------------------------- Bluetooth ------------------------------- */

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    /* -------------------------------- Printing -------------------------------- */

    services.printing.enable = true;
    services.colord.enable = true;

  };
}
