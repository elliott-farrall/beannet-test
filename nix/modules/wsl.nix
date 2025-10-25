{ inputs, ... }:

{
  flake.modules.nixos.default = { lib, config, ... }: {
    imports = with inputs; [ nixos-wsl.nixosModules.default ];

    config = lib.mkIf config.wsl.enable {
      wsl.wslConf.network.generateResolvConf = false;

      programs.nix-ld.enable = true; # Allows vscode remote access

      environment.persistence = {
        data.enable = lib.mkForce false;
        state.enable = lib.mkForce false;
        log.enable = lib.mkForce false;
      };
    };
  };
}
