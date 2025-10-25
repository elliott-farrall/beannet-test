{ ... }:

{
  flake.clan.machines."soy" = { ... }: {
    wsl.enable = true;
    nixpkgs.hostPlatform.system = "x86_64-linux";
  };
}
