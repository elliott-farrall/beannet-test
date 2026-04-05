{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    boot = {
      kernelParams = [ "boot.shell_on_fail" ];
    };
  };
}
