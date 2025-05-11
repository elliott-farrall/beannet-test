{ inputs, ... }:

{
  flake.modules.nixos."shared" = { ... }: {
    imports = with inputs; [ preservation.nixosModules.preservation ];

    preservation = {
      enable = true;

      preserveAt."/persist" = {
        commonMountOptions = [ "x-gvfs-hide" "x-gdu.hide" ];

        directories = [
          { directory = "/var/lib/nixos"; inInitrd = true; }
        ];
        files = [
          { file = "/etc/machine-id"; inInitrd = true; }
        ];
      };
    };

    fileSystems."/persist".neededForBoot = true;
  };
}
