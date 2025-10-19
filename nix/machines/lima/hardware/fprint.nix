{ ... }:

{
  flake.clan.machines."lima" = { ... }: {
    environment.persistence.state.directories = [
      "/var/lib/fprint"
    ];
  };
}
