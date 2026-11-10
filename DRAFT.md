# DRAFT - ojuny-minimal-template

Status: draft scope. Nothing is built. This file describes what the repository
is supposed to contain, not what it contains today.

## Purpose

The reference starter for people who want to build their own Ojuny template.
It is user-facing: fork it, strip or add what you need, and keep the parts that
make the configuration installable.

It is also the smallest honest example of the template shape the Ojuny
installers already accept. There is no special case for Minimal. The standard
`ojuny-installer` takes a template URL, and any template that installs, boots
and runs is interchangeable with any other.

## Position in the project

`ojuny-template` is the full desktop template. This repository is the base a
person starts from when the full template contains too much. Pro, Console and
Home Server are separate products, not derivatives that this repository must
track. They follow the same template shape so the installers can consume them.

The template definition is behavioral, not a versioned schema:

- the installer can install it correctly
- the setup script can install it correctly
- after installation, it boots and runs

Everything else is optional. `nix-settings-gui` is optional because the OS
installs and boots without it. Patches are optional because the OS installs and
boots without them. A desktop, an application set and a settings GUI can all be
added on top.

## What the repository will contain

```text
ojuny-minimal-template/
  flake.nix                  dendritic entrypoint
  flake.lock
  modules/
    01-users/                account module
    07-system/               host, hardware, networking, configuration
  scripts/                   setup and generator scripts
  docs/                      template requirements and setup notes
  tests/                     evaluation, setup and VM install checks
```

The tree should stay as small as possible. If a file is not needed for the
install and boot path, it does not belong in the starter.

### Flake outputs

- `nixosConfigurations.<host>`: the buildable `x86_64-linux` system.
- `apps.setup`: the host setup app.
- `apps.generate-hw`, `apps.generate-user`, `apps.create-new-system`.

Optional outputs such as `nixosModules.default` are added only when they help a
consumer. They are not part of the minimum.

### Modules

- A generated hardware module at `modules/07-system/00-hardware.nix`.
- A generated host registration module at `modules/07-system/00-host.nix`.
- A generated user module at `modules/01-users/01-user.nix`.
- Base system configuration for networking, boot, users and state version.
- No desktop, compositor, application pages, settings GUI, patch switch or
  gaming pages by default. These are additions a user makes after forking.

### Scripts

- `setup.sh`: clone a fork, generate hardware, user and host, offer a rebuild.
- `generate-hw.sh`: write the hardware module and `facter.json`.
- `generate-user.sh`: write the user module with a hashed password.
- `create-new-system.sh`: register the host in `flake.nix`.

### Documentation

- What makes a template installable and bootable.
- The generated file paths and the prompts that produce them.
- How the setup script is invoked and what it writes.
- How to add a desktop, settings GUI or patches after forking.
- A module tree generated from the repository.

### Tests

- Clean-clone evaluation of the host.
- A NixOS VM boot test.
- A setup-script run that produces a valid host, user and hardware module.
- An install driven by the standard installer.
- A boot of the installed system.

## Minimum template requirements

This is the whole contract. A template is valid when it meets these conditions:

1. An `x86_64-linux` flake with at least one `nixosConfigurations.<host>`.
2. A build that needs no hand-edited machine data in tracked files.
3. Generated hardware, user and host modules at the documented paths.
4. Flake apps for setup and for the generators.
5. No personal names, hostnames, disk UUIDs, keys or password hashes.
6. An install path that works with `nixos-install --flake`.
7. The ability to accept an injected user, hostname and hardware profile from
   an installer without editing the hand-written pages.
8. After installation, the system boots and runs.

A settings GUI, a patch switch, a desktop and an application catalog are not
requirements. A template can add them, but the install and boot path must not
depend on them.

## Limits and non-goals

- No desktop environment and no graphical session in the starter.
- No application catalog beyond the base system.
- No installer implementation. That is `ojuny-minimal-installer`.
- No fleet, server, NAS or gaming features.
- No secrets store, no binary cache and no Hydra.
- No multiple-host shape in the starter. A user can add it after forking.
- No promise that the starter is a comfortable daily-driver desktop. It is a
  base for building one.

## Open questions

- Which base system settings belong in the starter, and which should the setup
  script generate instead?
- Should the starter include a single settings page as a worked example, or
  leave the settings GUI entirely to the user?
- How should the template requirements be checked by the installer: build and
  boot test, a static check, or both?

## Sources

- `ojuny-template/docs/00-overview.md`, `01-architecture.md`,
  `03-host-setup.md`.
- `ojuny-docs/02-project-architecture.md`, `08-scope-and-non-goals.md`.
- `ojuny-installer/README.md` for the template URL and install paths.
- `nixos-configs/notes/Ojuny Deployment Methods.md`.
