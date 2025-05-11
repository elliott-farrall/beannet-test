{ ... }:

{
  flake.modules.homeManager."components/swayosd" = { ... }: {
    services.swayosd.enable = true;
  };
}
