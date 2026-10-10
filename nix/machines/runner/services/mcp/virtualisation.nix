{ ... }:

{
  flake.clan.machines."runner" = { ... }:
    {
      virtualisation.podman.enable = true;
      virtualisation.oci-containers.backend = "podman";
    };
}
