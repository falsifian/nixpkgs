{ haskellLib }:

let inherit (haskellLib) doJailbreak dontHaddock dontCheck;
in self: super: {
  haddock-library-ghcjs = doJailbreak (dontCheck super.haddock-library-ghcjs);
  haddock-api-ghcjs = doJailbreak (dontHaddock super.haddock-api-ghcjs);
}
