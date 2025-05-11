{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    boot = {
      kernelParams = [ "boot.shell_on_fail" ];

      # TODO - Do we need this?
      initrd.kernelModules = [ "i915" ]; # Early KMS
    };
  };
}
