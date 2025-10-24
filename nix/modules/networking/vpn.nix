{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    environment.persistence.state.directories = [ "/var/lib/zerotier-one" ];
  };
}
