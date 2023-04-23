# Minimal image

## Requirements

- A minimal setup from this [workshop](./00-nix-installation/ReadMe.md)

## ToDo

- [ ] Try with [nixos-generators](https://github.com/nix-community/nixos-generators)

## Steps

Let's initialize a flake:

```bash
nix flake init
```

Nix create a `flake.nix` file containing a minimal setup.

We need to lock our flake to define the main dependency `nixpkgs`:

```bash
nix flake lock
```

Repl exploration:

```repl
nix repl
:lf . #Load Nix flake
packages # hit tab for autocomple
packages.x86_64-linux # hit tab

packages.x86_64-linux.default # hit enter

:e packages.x86_64-linux.default # To open derivation

:b packages.x86_64-linux.default # To build derivation

:q # To exit
```

Show package content in store:

```bash
tree /nix/store/1pry7pnxqig0n2pkl4mnhl76qlmkk6vi-hello-2.12.1
```

Build packages:

```bash
nix build # to build the default package
nix build .#hello # to build the hello package
nix build nixpkgs#cowsay #to build a package from nixpkgs
```

Run packages:

```bash
nix run
nix run nixpkgs#cowsay hello
```

Look at the Flakes feature documentation: <https://nixos.wiki/wiki/Flakes>

Add nixpkgs channel to inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  };
}
```

Update flake lock file:

```bash
nix flake lock
```

To create a `system` configuration we need to use `nixpkgs.lib.nixosSystem`:

```nix
{
  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [];
    };
  };
}
```

Let's try to check if our configuration is valid with:

```bash
nix flake check
```

Output:

```bash
error:
       Failed assertions:
       - The ‘fileSystems’ option does not specify your root file system.
       - You must set the option ‘boot.loader.grub.devices’ or 'boot.loader.grub.mirroredBoots' to make the system bootable.
(use '--show-trace' to show detailed location information)
```

We need to define the `fileSystems` option and target a "device" (something like `/dev/sda`) to be able build a minimal `nixosSystem`.

To define "things" such as the `fileSystems` option in our configuration we need to put them in the `modules` argument.

Each module specified will receive arguments as described here: <https://nixos.wiki/wiki/NixOS_modules#Function>

We can either directly embded it or specify a file to import:

```nix
{
  system = "x86_64-linux";
  modules = [
    ({ config, pkgs, ... }: {
      # my config
    })
    ./machine.nix
  ];
}
```

To ease our workshop and not overload our brain with too much information we will import an installer module provided by the nixpkgs repository:

```nix
{
  modules = [
    ({ modulesPath, ... }: {
      imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
      ];
    })
  ]
}
```

This will help us to produce an image with predefined `fileSytems` and other neat configurations.

Don't hesitate to have a look to the file which is imported by `installation-cd-minimal.nix`: <https://github.com/NixOS/nixpkgs/blob/nixos-22.11/nixos/modules/installer/cd-dvd/iso-image.nix>

Do you remember how to build a something from `nix repl`? Let's do it again, according to the module we imported:

```nix
# This module creates a bootable ISO image containing the given NixOS
# configuration.  The derivation for the ISO image will be placed in
# config.system.build.isoImage.
```

```repl
:lf .
nixosConfigurations # hit tab
nixosConfigurations.default # again ...
nixosConfigurations.default.config.system.build.isoImage # it's a derivation so we can build it
:b nixosConfigurations.default.config.system.build.isoImage # build a derivation from repl is silent so you will have to wait until the build has finished
```

Let's add a package target:

```nix
{
  packages.x86_64-linux.isoImage = self.nixosConfigurations.default.config.system.build.isoImage;
}
```

Build it from `nix build` command:

```bash
nix build .#isoImage
```

Our image is now build and locate in the following folder:

```bash
ls result/iso
```

We now have a minimal image to use on a USB stick.
