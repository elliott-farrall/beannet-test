{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    stylix.targets.grub.enable = false;
  };
}
