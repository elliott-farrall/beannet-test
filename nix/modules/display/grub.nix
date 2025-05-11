{ ... }:

{
  flake.modules.nixos."default" = { lib, config, ... }:
    let
      cfg = config.display;
      enable = cfg.enable && config.boot.loader.grub.enable;

      inherit (cfg) width height;
    in
    {
      config = lib.mkIf enable {
        boot.loader.grub.gfxmodeEfi = "${toString width}x${toString height}";
      };
    };
}
