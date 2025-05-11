{ inputs, ... }:

{
  flake.clan.machines."sprout" = { ... }: {
    imports = with inputs.nixos-hardware.nixosModules; [
      common-pc
      common-pc-ssd
      common-cpu-intel-cpu-only
    ];
  };
}
