{ ... }:

{
  flake.modules.homeManager."programs/discord" = { pkgs, ... }: {
    home.packages = with pkgs; [
      discord
      vesktop
    ];

    desktop.wmIcons."discord" = "󰙯";
  };
}
