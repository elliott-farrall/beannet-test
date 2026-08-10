{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    services.kmscon = {
      enable = true;
      config.hwaccel = true;
    };
  };
}
