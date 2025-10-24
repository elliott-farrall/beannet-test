{ config, ... }:

let
  inherit (config.flake) modules;
in
{
  flake.modules.nixos.default = { lib, ... }: {
    imports = with modules.nixos; [ shell-bash ];

    options = {
      shell.bash.enable = lib.mkEnableOption "bash";
    };
  };

  flake.modules.nixos.shell-bash = { lib, config, ... }: {
    config = lib.mkIf config.shell.bash.enable {
      home-manager.sharedModules = with modules.homeManager; [ shell-bash ];
    };
  };

  flake.modules.homeManager.shell-bash = { ... }: {
    config = {
      programs.bash.enable = true;
    };
  };
}
