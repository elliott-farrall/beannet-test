{ inputs, ... }:

{
  flake.modules.nixos."users/elliott" = { lib, config, ... }: {
    imports = with inputs; [ clan-core.clanModules.user-password ];

    clan.user-password.user = "elliott";

    users.users.elliott = {
      uid = 1001;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFmUNOJdQxJX+v6+fTY7mQzUFjeRajUYPtjtVNilY/jN"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCejwvxNLgqkvej5gm5ybwj/cBkqZTfvhYLEoOLepQGb2lhnILL7A1gA0q2XkVYA2tvttm+QsTMxCkRFQ3yXVfko7+obGqNJJ95hGeqxwZw6+DHFhdx3mk4lxGfm+siqwm0LhyugH6USIzkKST3/QjgmK2ZsyQtrvdDYoPwl/JOBdEtaL1lCc2PoqBbIOR2a0kK1xbiLRVc3rkcKoF1suZIwRvh7XyxzQxoVv5S5pwMbm0ePFgIQtEsAF80MvRrKs0agMWTwhzdWHo4iWLHyVCjMi4tHQyJZ0OnFuuhys5IA2cySkkSQur8QdLPKPt4MrESwlaNOVh2D54VbgKefuJow0NByI5Ua95Jr4v+HqHYZQAxTcBCvnhEy4PHEcwTR0w7mRcDbP+Y09m/C786zW+FdIRrRHGmjz+jhfcFC3Zk1ehIauJrPxRKFM0gyfdqcRUfEVBBfWkbfdBVK9FjFBmAzXk6Ci6K85FlZqRWFWbT3uZGp95dnh5bqx+FwAPVvaBpwUpsccoHP0vMmL9pWZXtUizZH9CLow0+sdgLgtQtdeQr8XuPXzNrI8gkMetQtzN8u0clWFU571ipArPuQ5W0F3gCSYczEx0XZ38kEHUo4QFwUJkGtse4H3cklUyYtkQcsRDs4Qt/EgmqKiDv5ceHBcZCKcSvTJKJDi/PbzeFhQ=="
      ];

      extraGroups = [
        "wheel"
        (lib.mkIf config.programs.adb.enable "adbusers")
        (lib.mkIf config.virtualisation.docker.enable "docker")
        (lib.mkIf config.services.printing.enable "lpadmin")
        (lib.mkIf config.networking.networkmanager.enable "networkmanager")
        (lib.mkIf config.hardware.openrazer.enable "openrazer")
        (lib.mkIf config.virtualisation.podman.enable "podman")
      ];
    };

    home-manager.users.elliott.imports = with inputs.self.modules; [ homeManager."users/elliott" ];
  };

  flake.modules.homeManager."users/elliott" = { ... }: {
    imports = with inputs.self.modules; [
      homeManager."profiles/uos"
    ];
  };
}
