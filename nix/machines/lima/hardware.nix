{ inputs, ... }:

{
  flake.clan.machines."lima" = { ... }: {
    imports = with inputs.nixos-hardware.nixosModules; [ framework-12th-gen-intel ];

    clan.core.networking.targetHost = "";

    display = {
      enable = true;
      output = "eDP-1";

      width = 2256;
      height = 1504;

      refresh = 60;

      scale = 1.333333;
    };
  };
}
