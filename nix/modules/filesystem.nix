{ inputs, ... }:

{
  flake.modules.nixos."default" = { ... }: {
    imports = with inputs; [ impermanence.nixosModules.impermanence ];

    programs.fuse.userAllowOther = true; # Enables --allow-other in mounts;

    environment.persistence.data = {
      enable = true;
      hideMounts = true;
      persistentStoragePath = "/pst/data";
    };

    environment.persistence.state = {
      enable = true;
      hideMounts = true;
      persistentStoragePath = "/pst/state";

      directories = [ "/var/lib/nixos" ];
      files = [ "/etc/machine-id" ];
    };

    environment.persistence.log = {
      enable = true;
      hideMounts = true;
      persistentStoragePath = "/pst/log";
    };
  };

  flake.modules.homeManager."default" = { config, ... }: {
    imports = with inputs; [ impermanence.homeManagerModules.impermanence ];

    programs.rclone.enable = true;

    home.persistence.data = {
      enable = true;
      allowOther = true;
      persistentStoragePath = "/pst/data/home/${config.home.username}";

      directories = [ "Downloads" ];
    };

    home.persistence.state = {
      enable = true;
      allowOther = true;
      persistentStoragePath = "/pst/state/home/${config.home.username}";

      files = [ ".config/sops/age/keys.txt" ];
    };

    home.persistence.log = {
      enable = true;
      allowOther = true;
      persistentStoragePath = "/pst/log/home/${config.home.username}";
    };
  };
}
