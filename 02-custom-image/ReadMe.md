# Custom image

Requirements:

- A minimal image from this [workshop](../01-minimal-image/ReadMe.md)

## Steps

Maybe one of the first thing you might want to do when you booted your device from an image is to connect to it through SSH instead of relying on the main terminal so you can for example copy/paste commands directly from your computer.

To do this we need to install an OpenSSH server and add our public SSH key to the authorized keys of the main user.

We could install the package and configure it manually but instead we will be using a nixos module that will automatically do this for us.

This module can be searched from several places with `services.openssh`:

- https://nixos.org/nixos/options.html
- man configuration.nix

We can see that there is an option called `services.openssh.enable` but fortunately with the import `"${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"`, OpenSSH server is already enabled [here](https://github.com/NixOS/nixpkgs/blob/nixos-22.11/nixos/modules/profiles/installation-device.nix#L71). 

If we explore a little bit the code where is enabled the OpenSSH service, we can see that we need to add a public SSH key to the `nixos` user if we want to automatically be able to login. 

To do that search for the `authorizedKeys` word, you should find some of these options:

- `services.openssh.authorizedKeysFiles`
- `users.users.<name>.openssh.authorizedKeys.keys`
- `users.users.<name>.openssh.authorizedKeys.keyFiles`

The option `users.users.<name>.openssh.authorizedKeys.keys` is what we need, just replace `<name>` with `nixos` which is the default user configured by our import:

```nix
{
  modules = [
    ({ modulesPath, ... }: {
      imports = [
        "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
      ];

      users.users.nixos.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3N... "
      ];
    })
  ];
}
```

Now if we build our image, we will be able to SSH on a device that booted with our image.

Let's try on VM by running:

```bash
nix build .#nixosConfigurations.default.config.system.build.vm # yes you can build a VM just like that
export QEMU_NET_OPTS="hostfwd=tcp::2222-:22"
./result/bin/run-nixos-vm
```

In another terminal:

```bash
ssh -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no nixos@localhost -p 2222
cat /etc/ssh/authorized_keys.d/nixos
```

We now have an image containing our public SSH key.

You can go further and pre-install packages like `tmux`, configure services or pre-configure WiFi setup.
