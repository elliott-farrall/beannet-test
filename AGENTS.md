# AGENTS.md

Guidance for AI agents working in this repository.

## Project overview

This is a [NixOS](https://nixos.org/) configuration for a personal network of
machines ("beannet"), managed using the [Clan](https://clan.lol/) framework for
multi-machine deployment. Flake inputs are pinned in `flake.lock`.

## Repository structure

```text
flake.nix      # Entry point — feeds ./nix into flake-parts via import-tree
nix/
  flake/       # Flake-parts modules (outputs, devshells, formatter, hooks, clan)
  machines/    # Per-machine NixOS configurations
  modules/     # Reusable NixOS/home-manager modules
  services/    # (runner-specific) service definitions
  disks/       # Disk partitioning configs
machines/      # Clan machine metadata (facter.json hardware reports)
sops/          # Age keys and encrypted secrets (do not modify directly)
vars/          # Clan-generated runtime variables (do not modify directly)
inventory.json # Clan inventory metadata (managed by clan-cli)
```

## Architecture patterns

### import-tree + flake-parts

`flake.nix` passes the entire `nix/` directory to `import-tree`, which
recursively loads every `.nix` file as a flake-parts module. There is no
explicit import list — adding a `.nix` file to the tree is sufficient for it
to be picked up.

Every file should be a valid flake-parts module (i.e. a function taking
`{ inputs, ... }` and returning an attrset).

### Module conventions

- Reusable NixOS modules are exported under `flake.modules.nixos.<name>`.
- Reusable home-manager modules are exported under
  `flake.modules.homeManager.<name>`.
- Machine-specific config lives in `nix/machines/<hostname>/`.
- Prefer small, focused files over large monolithic ones.

### Machines

| Hostname | Tag | Role |
| -------- | --------- | ------------------------------------------------- |
| runner | server | Cloud VPS on Hetzner; Traefik, Authelia, LLDAP |
| sprout | server | Router/firewall; PPPoE, DNS, WiFi |
| broad | server | Desktop with NVIDIA GPU |
| lima | laptop | Framework 12th-gen laptop |
| kidney | installer | Minimal installer/bootstrap image |
| soy | wsl | Windows Subsystem for Linux |

## Development environment

A devshell is provided. Enter it with:

```sh
nix develop
# or, if direnv is configured:
# direnv allow
```

The devshell includes `clan-cli`, `clan-app`, and helper scripts
(`runner-install`, `runner-update`).

### Ephemeral tools

Use `comma` or `nix shell` for tools not permanently installed:

```sh
, <tool>                              # run a tool ephemerally via comma
nix shell nixpkgs#<tool> -c <tool>   # explicit nix shell
```

## Common tasks

### Before committing

Always run pre-commit checks before committing. The hooks enforce formatting,
linting, and secret hygiene:

```sh
pre-commit run --all-files
```

If `treefmt` modifies files, stage the changes and run again. Hooks run
automatically on `git commit` but running them manually first avoids a failed
commit.

### Format code

```sh
treefmt   # formats all supported file types
```

Covers Nix (`nixpkgs-fmt`, `statix`, `deadnix`), JSON, YAML, TOML, and
Markdown. Excludes `sops/**`, `vars/**`, `inventory.json`, `**/facter.json`.

### Build a machine

```sh
nix build .#nixosConfigurations.<hostname>.config.system.build.toplevel
```

### Deploy via Clan

```sh
clan machines update <hostname>    # deploy to an existing machine
clan machines install <hostname>   # initial install
```

## Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix)
integrated through Clan, using age encryption.

- Per-machine age keys are in `sops/machines/<hostname>/key.json`.
- Encrypted secret material is in `sops/secrets/`.
- Runtime variables (Clan generators: JWT keys, session tokens, etc.) live in
  `vars/` — do not edit by hand.
- Never commit plaintext secrets. The `ripsecrets` and
  `pre-commit-hook-ensure-sops` hooks guard against this.
- Secrets are passed to services at runtime via systemd `LoadCredential`.

## CI/CD

Currently minimal. The repository is hosted on GitHub and uses pre-commit hooks
as the primary automated quality gate. A move to Azure DevOps is under
consideration. Do not assume any particular CI pipeline is active.

## NixOS environment

Machines in this project run NixOS. When working in this repo on a NixOS
machine, be aware of the following.

**Read-only paths**: `/nix/store` and all nix-managed paths are immutable.
Many files under `~/.config` and `~/.local` are symlinks into the nix store —
do not attempt to write to them. Use `readlink -f <path>` to check.

**Impermanence**: The root filesystem is ephemeral and reset on reboot.
Persistent data lives under `/pst`:

| Path | Purpose |
| ------------------------- | ---------- |
| `/pst/data/home/<user>/` | User data |
| `/pst/state/home/<user>/` | User state |
| `/pst/log/home/<user>/` | User logs |

When adding state or config that must survive reboots, declare it in
`home.persistence.data.directories` or `home.persistence.state.directories`
inside the relevant home-manager module.

**Running tools**: Not all tools are globally installed. Use `comma` or
`nix shell` to run tools ephemerally:

```sh
, <tool>                                   # comma (finds package automatically)
nix shell nixpkgs#<pkg> --command <tool>   # explicit nix shell
```

Further reading:
[NixOS manual](https://nixos.org/manual/nixos/stable/) ·
[home-manager manual](https://nix-community.github.io/home-manager/) ·
[impermanence module](https://github.com/nix-community/impermanence)

## Things to avoid

- Do not edit `sops/`, `vars/`, `machines/` (facter.json), or `inventory.json`
  manually — these are managed by Clan tooling.
- Do not add `dep_`-prefixed inputs unless you intend them to be excluded from
  flake outputs (convention for hiding internal inputs).
- Do not bypass pre-commit hooks (`--no-verify`).
