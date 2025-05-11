{ ... }:

{
  flake.clan.machines."lima" = { ... }: {
    preservation.preserveAt.state.directories = [
      "/var/lib/fprint"
    ];
  };
}
