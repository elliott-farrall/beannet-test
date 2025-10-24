{ ... }:

{
  flake.modules.homeManager.default = { ... }: {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;

      silent = true;
      config.global.warn_timeout = 0;
    };
  };
}
