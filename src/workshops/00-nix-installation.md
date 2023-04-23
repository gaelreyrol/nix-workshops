# Nix installation

## Requirements

- Linux, MacOS, Windows (WSL2)

## ToDo

- Try installation with [nix-installer](https://github.com/DeterminateSystems/nix-installer)

## Steps

For Linux users with install Nix:

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Enable expirmental features but not so expiremental:

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

Don't forget to restart nix-daemon.

```bash
systemctl restart nix-daemon
```

Let's play a litte bit with Nix:

- [ ] Language
- [ ] Channels
- [ ] Nixpkgs
- [ ] Repl
