{ ... }:

{
  flake.modules.homeManager."programs/davinci-resolve" = { pkgs, ... }: {
    home.packages = with pkgs; [ davinci-resolve ];
  };
}
