{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    boot = {
      kernelParams = [ "boot.shell_on_fail" ];

      # REVIEW - This may not be necessary
      initrd.kernelModules = [ "i915" ]; # Early KMS
    };
  };
}
