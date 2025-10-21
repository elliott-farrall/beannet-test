{ inputs, ... }:

{
  flake.modules.homeManager."default" = { config, ... }: {
    imports = with inputs; [ clan-core.inputs.sops-nix.homeManagerModules.sops ];

    sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
  };
}
