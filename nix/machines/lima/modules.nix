{ config, ... }:

{
  clan.machines."lima" = { ... }: {
    imports = with config.flake.modules; [
      nixos."default"
      nixos."shell/zsh"
      nixos."greeter/tuigreet"
      nixos."users/elliott"
    ];
  };
}
