{ ... }:

{
  flake.clan.machines."lima" = { ... }: {
    boot = {
      kernelParams = [
        "boot.shell_on_fail" # Allows for root shell if failure to boot. Requires root password.
      ];

      initrd.kernelModules = [ "i915" ]; # Early KMS

      loader = {
        grub = {
          enable = true;
          device = "nodev";
        };
        timeout = 3;
      };
    };
  };
}
