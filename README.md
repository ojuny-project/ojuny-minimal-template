# ojuny-minimal-template

The bare minimum valid Ojuny template. It installs with the standard setup
script or the standard installer, boots to a console login, and leaves
desktops, settings GUIs, applications and patches to the fork.

## Use

```console
nix run .#setup
```

The setup app clones your fork, generates the hardware, user and host modules,
and offers a rebuild. The generated files are:

- `modules/00-hardware.nix`
- `modules/00-host.nix`
- `modules/00-user.nix`

To check a fork before installing it:

```console
nix run .#check
```

The check verifies the required module names, the required scripts and at
least one `nixosConfigurations` host. `nix run .#check -- --system` also
evaluates the system toplevel after the hardware module has been generated.
`nix run .#check -- --static` skips Nix evaluation.

## What is included

- A dendritic flake with `nixpkgs`, `flake-parts` and `import-tree`.
- Base system configuration: hostname, state version, locale, keymap,
  NetworkManager and flakes.
- Generated hardware, bootloader, user and host modules.
- The setup and generator scripts.
- The `check` app and a static `checks.template`.

## What is not included

No desktop, compositor, settings GUI, application catalog, patches, secrets,
binary cache, installer implementation, Home Manager or multi-host shape. Add
those after forking. The generator and installer omit the Home Manager block
when the flake has no `home-manager` input. See `DRAFT.md` for the full scope
and the template requirements.
