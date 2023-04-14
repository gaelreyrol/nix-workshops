{
  description = "Nix workshops flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  };

  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {
    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = with pkgs; [
        mdbook
      ];
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
      checkInputs = with pkgs; [ mdbook ];
      checkPhase = ''
        runHook preCheck

        mdbook test

        runHook postCheck
      '';
    };
  };
}
