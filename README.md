

[![built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)](https://builtwithnix.org) [![Build x86](https://github.com/dr460nf1r3/dr460nixed/actions/workflows/cachix_x86.yml/badge.svg)](https://github.com/dr460nf1r3/dr460nixed/actions/workflows/cachix_x86.yml) [![Sync Tailscale ACLs](https://github.com/dr460nf1r3/dr460nixed/actions/workflows/tailscale.yml/badge.svg)](https://github.com/dr460nf1r3/dr460nixed/actions/workflows/tailscale.yml)

# My personal 'try' NixOS flake & system configurations

This repo contains my NixOS dotfiles. All of my personal devices are going to be added here over time.

![desktop-kde](https://i.imgur.com/hZQj0fi.png)

**What is inside?**:

- Multiple **NixOS configurations**, including **desktop**, **server**, **nixos-wsl** & **live-usb**
- A fully ported & configured **Garuda dr460nized KDE** setup: **Dr460nixed** !
- **Opt-in persistence** through impermanence + ZFS snapshots
- **Mesh networked** hosts with **Tailscale**
- Additional packages not existing in Nixpkgs (yet) via **chaotic-nyx**
- Secrets are managed via **nix-sops**
- Automated flake building when pushing to main & pushing to **Cachix** via **GitHub Actions**
- Easy building of configurations & deployment via **Colmena**

Other, smaller tweaks I particularly like about this setup include:

- A much enhanced, fancy themed Spotify **via spicetify-cli**
- No password prompts when having my **Yubikey** connected to my laptop
- Being able to easily remote-control my machines via **KDEConnect**
- Having custom, (sometimes too) **bleeding-edge Mesa** builds

## Structure

- `flake.nix`: Entrypoint for hosts and home configurations. Also exposes a
  devshell for boostrapping (`nix develop` or `nix-shell`) as well as Colmena configs.
- `apps`: Packages built from source.
- `configurations`: All the Nix configurations not available via modules
- `hosts`: NixOS Configurations, accessible via `nixos-rebuild --flake`.
- `modules`: The major part of the system configurations, exposes `dr460nixed.*` options
- `overlays`: Patches and version overrides for some packages.
- `pkgs`: My custom packages.

## Module options

- `dr460nixed.common.enable` = true - common options for every system
- `dr460nixed.desktops.enable` = false - options for desktop systems
- `dr460nixed.development.enable` = false - enables a development environment
- `dr460nixed.gaming.enable` = false - gaming related apps & options
- `dr460nixed.hardening.enable` = true - system hardening
- `dr460nixed.live-cd` = false - live CD applications
- `dr460nixed.performance-tweaks` = false - performance enhancing options
- `dr460nixed.rpi` = false - Raspberry Pi related things
- `dr460nixed.school` = false - things I need for school
- `dr460nixed.servers.enable` = false - common server options
- `dr460nixed.shells` = true - enables common shell aliases & theming
- `dr460nixed.systemd-boot` = true - a quiet systemd-boot configuration
- `dr460nixed.yubikey` = false - options for using the Yubikey as login

## How to bootstrap

All you need is nix (any version). Run:

```
nix-shell
```

If you already have nix 2.4+, git, and have already enabled `flakes` and
`nix-command`, you can also use the non-legacy command:

```
nix develop
```

`nixos-rebuild --flake .` To build system configurations

## Credits

A special thanks to  [dr460nf1r3](https://github.com/dr460nf1r3) , [PedroHLC](https://github.com/pedrohlc) and [Mysterio77](https://github.com/Misterio77), as well as to [NotAShelf](https://github.com/NotAShelf) - their Nix configurations helped tremendously while setting all of this up.
