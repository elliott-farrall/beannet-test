{ ... }:

{
  flake.modules.nixos.default = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ terraform ];
  };

  flake.modules.homeManager.default = { ... }: {
    home.persistence.state.files = [ ".terraform.d/credentials.tfrc.json" ];
  };
}
