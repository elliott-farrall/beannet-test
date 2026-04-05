{ inputs, config, ... }:

with inputs.nixos-hardware.nixosModules;
with config.flake.modules.nixos;
let
  public_key = builtins.readFile "${config.flake.clan.directory}/vars/per-machine/runner/sshd-root-key/id_ed25519.pub/value";
in
{
  flake.clan.machines."runner" = { lib, ... }: {
    imports = [
      disks-zfs
    ];

    disko.devices.disk."main".device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_115217896";

    boot.loader = {
      grub.efiSupport = lib.mkForce false;
      efi.canTouchEfiVariables = lib.mkForce false;
    };
  };

  perSystem.terranix.terranixConfigurations."runner" = {
    workdir = "result";

    modules = [
      {
        terraform.backend.remote = {
          organization = "elliott-farrall";
          workspaces.name = "bean-runner";
        };

        terraform.required_providers.hcloud = {
          source = "hetznercloud/hcloud";
          version = "~> 1.57.0";
        };

        resource.hcloud_ssh_key.this = {
          name = "runner - root";
          inherit public_key;
        };

        resource.hcloud_server.this = {
          name = "runner";
          server_type = "cx23";
          image = "ubuntu-22.04";

          ssh_keys = [ "\${ hcloud_ssh_key.this.id }" ];

          user_data = ''
            #cloud-config

            runcmd:
            - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=hetznercloud NIX_CHANNEL=nixos-24.05 bash 2>&1 | tee /tmp/infect.log
            - shutdown -r 0
          '';
        };

        output.ipv4_address.value = "\${ hcloud_server.this.ipv4_address }";
        output.ipv6_address.value = "\${ hcloud_server.this.ipv6_address }";
      }
    ];
  };
}
