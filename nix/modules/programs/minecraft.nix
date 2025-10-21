{ ... }:

{
  flake.modules.homeManager."programs/minecraft" = { pkgs, ... }: {
    home.packages = with pkgs; [ prismlauncher ];
  };
}
