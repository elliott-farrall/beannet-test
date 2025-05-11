{ inputs, ... }:

{
  flake.clan.machines."lima" = { ... }: {
    imports = with inputs.nixos-hardware.nixosModules; [
      framework-12th-gen-intel
    ];
  };
}
