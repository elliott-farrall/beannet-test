{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 30 --keep-since 14d";
      };
    };
  };
}
