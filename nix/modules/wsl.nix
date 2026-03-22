{ inputs, ... }:

{
  flake.modules.nixos.default = { lib, config, ... }: {
    imports = with inputs; [ nixos-wsl.nixosModules.default ];

    config = lib.mkIf config.wsl.enable {
      # wsl.wslConf.network.generateResolvConf = false;
      # networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
      networking = {
        defaultGateway = {
          address  = "172.23.16.1";
          interface = "eth0";
        };

        interfaces."eth0" = {
          useDHCP = false;
          ipv4.addresses = [{ address = "172.23.16.2"; prefixLength = 20; }];
          mtu = 1400;
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
