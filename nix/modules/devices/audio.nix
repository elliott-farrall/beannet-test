{ ... }:

{
  flake.modules.nixos.default = { lib, config, ... }: {
    options = {
      devices.audio.enable = lib.mkEnableOption "audio";
    };

    config = lib.mkIf config.devices.audio.enable {
      services.pipewire = {
        enable = true;
        wireplumber.enable = true;
      };
    };
  };
}
