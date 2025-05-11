{ inputs, ... }:

{
  flake.clan.machines."soy" = { ... }: {
    imports = with inputs.nixos-hardware.nixosModules; [
      common-pc
      common-pc-ssd
      common-cpu-intel-cpu-only
      common-gpu-nvidia-nonprime
    ];

    hardware.nvidia.open = false;
  };
}
