{ haskellLib }:

let inherit (haskellLib) doJailbreak dontHaddock dontCheck;
in self: super: {
  ghcjs = super.ghcjs.override {
    base16-bytestring = super.base16-bytestring_0_1_1_7;
    optparse-applicative = super.optparse-applicative_0_15_1_0;
  };
  haddock-library-ghcjs = doJailbreak (dontCheck super.haddock-library-ghcjs);
  haddock-api-ghcjs = doJailbreak (dontHaddock super.haddock-api-ghcjs);
}
