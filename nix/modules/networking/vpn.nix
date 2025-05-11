{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    preservation.preserveAt."/persist".directories = [ "/var/lib/zerotier-one" ];
  };
}
