{ ... }:

{
  flake.modules.homeManager."desktop/components/swayosd" = { ... }: {
    services.swayosd.enable = true;
  };
}
