{ ... }:

{
  flake.modules.nixos.default = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ terraform ];
  };

  flake.modules.homeManager.default = { ... }: {
    home.persistence.state.directories = [ ".terraform.d" ];
  };
}
