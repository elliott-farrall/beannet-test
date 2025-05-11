{ ... }:

{
  flake.modules.nixos."shared" = { ... }: {
    stylix.targets.grub.enable = false;
  };
}
