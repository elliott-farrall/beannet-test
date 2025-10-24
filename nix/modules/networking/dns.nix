{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    networking.nameservers = [ "37.27.187.11" ];
  };
}
