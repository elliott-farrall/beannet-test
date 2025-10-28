{ inputs, ... }:

# TODO - Refactor to remove dependency on hcloud module

let
  privateKeyFile = "root-ssh.key";
in
{
  perSystem = { inputs', ... }: {
    terranix.terranixConfigurations."runner" = {
      terraformWrapper = {
        prefixText = ''
          rm -f ${privateKeyFile}
          clan vars get runner root/private-key > ${privateKeyFile}
          chmod 400 ${privateKeyFile}
        '';
        extraRuntimeInputs = with inputs'.clan-core.packages; [ clan-cli ];
      };
      workdir = "result";

      modules = with inputs; [
        {
          terraform.backend."remote" = {
            organization = "BeanNet";
            workspaces.name = "runner";
          };
        }
        terranix-hcloud.terranixModule
        {
          users.admins.root.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUjxl1444qMm7/Xp2MTZIoU31m1j/UsThn5a3ql1lD2";
          provisioner = { inherit privateKeyFile; };

          hcloud.nixserver."runner" = {
            enable = true;
            name = "runner";
            serverType = "cx22";
          };
        }
      ];
    };
  };
}
