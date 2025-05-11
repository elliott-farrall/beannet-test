{ ... }:

{
  flake.modules.nixos."default" = { lib, config, ... }:
    let
      cfg = config.display;
      enable = cfg.enable && config.boot.plymouth.enable;

      inherit (cfg) scale;
    in
    {
      config = lib.mkIf enable {
        boot.plymouth.extraConfig = "DeviceScale=${toString (builtins.ceil scale)}";
      };
    };
}
