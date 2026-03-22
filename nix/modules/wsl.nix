{ inputs, ... }:

{
  flake.modules.nixos.default = { lib, config, ... }: {
    imports = with inputs; [ nixos-wsl.nixosModules.default ];

    config = lib.mkIf config.wsl.enable {
      # wsl.wslConf.network.generateResolvConf = false;
      # networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
      systemd.network = {
        enable = true;

        networks."10-eth0" = {
          matchConfig.Name = "eth0";
          linkConfig.MTUBytes = "1400";
        };
      };

      programs.nix-ld.enable = true; # Allows vscode remote access

      environment.persistence = {
        data.enable = lib.mkForce false;
        state.enable = lib.mkForce false;
        log.enable = lib.mkForce false;
      };
    };
  };

  flake.modules.homeManager.default = { lib, nixosConfig, ... }: {
    config = lib.mkIf nixosConfig.wsl.enable {
      home.persistence = {
        data.enable = lib.mkForce false;
        state.enable = lib.mkForce false;
        log.enable = lib.mkForce false;
      };
    };
  };
}
