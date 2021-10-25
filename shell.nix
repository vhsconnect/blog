{ sources ? import ./nix/sources.nix }:
let
  pkgs = import sources.nixpkgs { };
  ghc = pkgs.haskellPackages.ghcWithHoogle
    (ps: with ps;
    [
      hakyll
      hlint 
      hindent
    ]);
in
pkgs.stdenv.mkDerivation {
  name = "my-haskell-env-0";
  buildInputs = [ ghc ];
  shellHook = "eval $(egrep ^export ${ghc}/bin/ghc) && ponysay 'in the shell'";
}
