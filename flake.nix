{
  description = "vhs' blog";

  inputs = {
    nixpkgs.url = "nixpkgs/046ee4af7a9f016a364f8f78eeaa356ba524ac31";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, utils, nixpkgs }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        env = pkgs.haskellPackages.ghcWithHoogle (p: with p ; [
          hakyll
          haskell-language-server
          hlint
          ormolu
          floskell
          hindent
          zlib
          ghcid
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ env pkgs.glibcLocales ];
        };
      }
    );
}
