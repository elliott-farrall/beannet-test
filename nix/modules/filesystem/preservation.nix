{ inputs, ... }:

let
  commonMountOptions = [ "x-gvfs-hide" "x-gdu.hide" ];
in
{
  flake.modules.nixos."default" = { ... }: {
    imports = with inputs; [ preservation.nixosModules.preservation ];

    preservation = {
      enable = true;

      preserveAt.data = {
        persistentStoragePath = "/pst/data";
        inherit commonMountOptions;
      };

      preserveAt.state = {
        persistentStoragePath = "/pst/state";
        inherit commonMountOptions;

        directories = [
          { directory = "/var/lib/nixos"; inInitrd = true; }
        ];
        files = [
          { file = "/etc/machine-id"; inInitrd = true; how = "symlink"; }
        ];
      };

      preserveAt.log = {
        persistentStoragePath = "/pst/log";
        inherit commonMountOptions;
      };
    };
  };
}
