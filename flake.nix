{
  description = "vhs' blog";

  inputs = {
    nixpkgs.url = "nixpkgs/046ee4af7a9f016a364f8f78eeaa356ba524ac31";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      utils,
      nixpkgs,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        env = pkgs.haskellPackages.ghcWithHoogle (
          p: with p; [
            hakyll
            haskell-language-server
            hlint
            ormolu
            floskell
            hindent
            zlib
            ghcid
          ]
        );
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "vhs-blog";
          src = ./.;
          nativeBuildInputs = [
            env
            pkgs.glibcLocales
            pkgs.cabal-install
          ];
          buildPhase = ''
            export HOME=$TMP
            cabal run site build
          '';
        };

        devShells.default = pkgs.mkShell {
          shellHook = ''
            cabal update
            cabal run site build
            echo ⛵
            exit
          '';
          buildInputs = [
            pkgs.cabal-install
            env
            pkgs.glibcLocales
          ];
        };
      }
    );
}
