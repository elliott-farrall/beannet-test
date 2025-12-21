{ inputs, ... }:

{
  flake.modules.nixos.default = { lib, config, ... }:
    {
      disabledModules = [ "services/ttys/kmscon.nix" ];
      imports = [ ./_overrides/kmscon.nix ];

      # services.greetd = {
      #   enable = true;

      #   # FIXME - Incorrect resolutions on multi-monitor setups
      #   settings.default_session.command = ''${lib.getExe pkgs.tuigreet} \
      #     --remember \
      #     --remember-session \
      #     --user-menu \
      #     --sessions ${desktops}/share/wayland-sessions \
      #     --xsessions ${desktops}/share/xsessions \
      #     --cmd zsh \
      #     --asterisks \
      #     --theme 'border=${accent'};prompt=${accent'};action=${accent'}'
      #   '';
      # };

      services.kmscon.extraConfig = ''
        login=${lib.getExe (inputs.lidm.defaultPackage.${config.nixpkgs.pkgs.system}.override (attrs: {
          config = attrs.config // { cfg = "nord";  };
        }))}
      '';
    };
}
