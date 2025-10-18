{ ... }:

let
  icon = builtins.fetchurl {
    url = "https://dotfiles.beannet.io/icons/minecraft.png";
    sha256 = "sha256:0jwvbfvy52scgvz4s4gnfq79wc93kq2j4lrwgmgaz7ljm9ysy2y5";
  };
in
{
  flake.modules.homeManager."programs/zotero" = { pkgs, ... }: {
    home.packages = [
      # TODO - Move to overlay
      (pkgs.symlinkJoin {
        name = "minecraft";
        paths = [ pkgs.prismlauncher ];
        postBuild = ''
          install -v ${pkgs.prismlauncher}/share/applications/org.prismlauncher.PrismLauncher.desktop $out/share/applications/org.prismlauncher.PrismLauncher.desktop
          substituteInPlace $out/share/applications/org.prismlauncher.PrismLauncher.desktop \
            --replace "Name=Prism Launcher" "Name=Minecraft" \
            --replace "Icon=org.prismlauncher.PrismLauncher" "Icon=${icon}"
        '';
      })
    ];
  };
}
