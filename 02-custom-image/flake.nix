{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  };

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ modulesPath, ... }: {
          imports = [
            "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
          ];

          users.users.nixos.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEDaOQVs/WLWCIahRTfAmolgLV2jWL6EasDM6O++rq1M"
          ];
        })
      ];
    };

    packages.x86_64-linux.isoImage = self.nixosConfigurations.default.config.system.build.isoImage;
    packages.x86_64-linux.vm = self.nixosConfigurations.default.config.system.build.vm;
  };
}
