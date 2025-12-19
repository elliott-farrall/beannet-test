{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    boot = {
      plymouth.enable = true;

      # silent boot configuration based on:
      #   https://github.com/Misterio77/nix-config/blob/a8727347957891bd651aba3bc0e04ca694d6f664/hosts/common/optional/quietboot.nix

      kernelParams = [
        "quiet"
        "loglevel=3"
        "systemd.show_status=auto"
        "udev.log_level=3"
        "rd.udev.log_level=3"
        "vt.global_cursor_default=0"
      ];

      consoleLogLevel = -1;
      initrd.verbose = false;
    };

    console = {
      useXkbConfig = true;
      earlySetup = false;
    };

    stylix.targets.plymouth.enable = false; # Managed by Catppuccin
  };
}
