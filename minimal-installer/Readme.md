# Minimal Installer

Requirements:

- Nix
- `experimental-features = nix-command flakes`


## Steps

Install Nix:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Enable some expirmental features but not so expiremental:

```
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Don't forget to restart nix-daemon.

Initialize flake:

```bash
nix flake init
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

Look at the Flakes feature documentation: https://nixos.wiki/wiki/Flakes

Add nixpkgs to inputs:

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

Create a configuration:

```nix
  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [];
    };
  };
```


Let's try to check if our configuration is valid with:

```bash
nix flake check
```

Output:

```
error:
       Failed assertions:
       - The ‘fileSystems’ option does not specify your root file system.
       - You must set the option ‘boot.loader.grub.devices’ or 'boot.loader.grub.mirroredBoots' to make the system bootable.
(use '--show-trace' to show detailed location information)
```

We need to define the `fileSystems` option and target a "device" (something like `/dev/sda`) to be able build a minimal `nixosSystem`.

To define "things" such as the `fileSystems` option in our configuration we need to put them in the `modules` argument.

Each module specified will receive arguments as described here: https://nixos.wiki/wiki/NixOS_modules#Function

We can either directly embded it or specify a file like so:

```nix
{
  modules = [
    ({ config, pkgs, ...}: {
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
        "${modulesPath}/installer/sd-card/sd-image-x86_64.nix"
      ];
    })
  ]
}
```

This will help us to produce an image with predefined `fileSytems` and other neat configurations.

Don't hesitate to have a look to the file: https://github.com/NixOS/nixpkgs/blob/nixos-22.11/nixos/modules/installer/sd-card/sd-image-x86_64.nix

Do you remember how to build a something from `nix repl`? Let's do it again, according to the module we imported:

```nix
# To build, use:
# nix-build nixos -I nixos-config=nixos/modules/installer/sd-card/sd-image-x86_64.nix -A config.system.build.sdImage
```

```repl
:lf .
nixosConfigurations # hit tab
nixosConfigurations.default # again ...
nixosConfigurations.default.config.system.build.sdImage # it's a derivation so we can build it
:b nixosConfigurations.default.config.system.build.sdImage # build a derivation from repl is silent so you will have to wait until the build has finished
```

Let's add a package target:

```nix
{
  packages.x86_64-linux.sdImage = self.nixosConfigurations.default.config.system.build.sdImage;
}
```

Build it from `nix build` command:

```bash
nix build .#sdImage
```

Our image is now build and locate in the following folder:

```
ls -la result/sd-image
```

We now have a minimal image to use on a USB stick.