{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    preservation.preserveAt.state.directories = [
      "/var/lib/zerotier-one"
    ];
  };
}
