{ ... }:

{
  flake.clan.machines."lima" = { ... }: {
    display = {
      enable = true;
      output = "eDP-1";

      width = 2256;
      height = 1504;

      refresh = 60;

      scale = 1.333333;
    };
  };
}
