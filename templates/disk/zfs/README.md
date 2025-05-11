---
description = "ZFS with EFI support for impermenant setups"
---

# ZFS

This template configures a single disk with a ZFS pool `nixos` and the following datasets:

- `/root` that is mounted to `/` and is reverted to an empty snapshot on boot.
- `/nix` mounted to `/nix`.
- `/sops` mounted to `/var/lib/sops-nix` for storing the age encryption key.
- `/persist` mounted to `/persist` for persisting other data using impermenance/preservation.
