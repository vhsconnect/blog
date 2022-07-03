{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs { };
  ghc = pkgs.haskellPackages.ghcWithHoogle
    (ps: with ps;
    [
      hakyll
      haskell-language-server
      hlint
      ormolu
      floskell
      hindent
      ghcid
    ]);
in
pkgs.stdenv.mkDerivation {
  name = "my-haskell-env-0";
  buildInputs = [ ghc pkgs.glibcLocales ];
  shellHook = "eval $(egrep ^export ${ghc}/bin/ghc) && ponysay 'in the shell'";
}
