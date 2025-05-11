{ ... }:

{
  flake.modules.nixos."shared" = { ... }: {
    fileSystems."/var/lib/sops-nix".neededForBoot = true;
  };
}
