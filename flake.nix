{
  description = "Nix workshops flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs@{ self, nixpkgs, pre-commit-hooks, treefmt-nix }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      formatter.x86_64-linux = treefmt-nix.lib.mkWrapper nixpkgs.legacyPackages.x86_64-linux {
        projectRootFile = "flake.nix";
        programs.nixpkgs-fmt.enable = true;
      };

      checks.x86_64-linux = {
        pre-commit-check = pre-commit-hooks.lib.x86_64-linux.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
            statix.enable = true;
            markdownlint.enable = true;
          };
          settings = {
            # https://github.com/DavidAnson/markdownlint/blob/main/schema/.markdownlint.jsonc
            markdownlint.config = {
              "MD013" = false;
              "MD042" = false;
            };
          };
        };
      };

      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [
          mdbook
          nixpkgs-fmt
          statix
          nodePackages.markdownlint-cli
        ];
        inherit (self.checks.x86_64-linux.pre-commit-check) shellHook;
      };

      packages.x86_64-linux.default = pkgs.stdenv.mkDerivation {
        name = "nix-workshops";
        src = ./.;
        doCheck = true;
        buildInputs = with pkgs; [ mdbook ];
        buildPhase = ''
          runHook preBuild

          mdbook build

          runHook postBuild
        '';
        installPhase = ''
          runHook preInstall

          cp -r book $out

          runHook postInstall
        '';
      };
    };
}
