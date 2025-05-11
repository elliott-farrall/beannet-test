{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    fileSystems."/var/lib/sops-nix".neededForBoot = true;
  };
}
