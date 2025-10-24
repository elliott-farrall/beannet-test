{ ... }:

{
  flake.modules.nixos.default = { ... }: {
    console.useXkbConfig = true;
    services.kmscon.useXkbConfig = true;

    time.timeZone = "Europe/London";
    i18n.defaultLocale = "en_GB.UTF-8";
    services.xserver.xkb.layout = "gb";
  };
}
