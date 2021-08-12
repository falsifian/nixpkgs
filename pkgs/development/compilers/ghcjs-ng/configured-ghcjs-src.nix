{ perl
, autoconf
, automake
, python3
, gcc
, cabal-install
, runCommand
, lib
, stdenv

, ghc
, happy
, alex

, ghcjsSrc
}:

runCommand "configured-ghcjs-src" {
  nativeBuildInputs = [
    perl
    autoconf
    automake
    python3
    ghc
    happy
    alex
    cabal-install
  ] ++ lib.optionals stdenv.isDarwin [
    gcc # https://github.com/ghcjs/ghcjs/issues/663
  ];
  inherit ghcjsSrc;
} ''
  export HOME=$(pwd)
  mkdir $HOME/.cabal
  touch $HOME/.cabal/config
  cp -r "$ghcjsSrc" "$out"
  chmod -R +w "$out"
  cd "$out"

  # TODO: Find a better way to avoid impure version numbers
  sed -i 's/RELEASE=NO/RELEASE=YES/' ghc/configure.ac

  # TODO: How to actually fix this?
  # Seems to work fine and produce the right files.
  touch ghc/includes/ghcautoconf.h
  touch ghc/utils/unlit/fs.h
  mkdir -p ghc/compiler/vectorise
  mkdir -p ghc/utils/haddock/haddock-library/vendor

  # Work around a version mismatch in the ghc-boot library.
  find ghc -type f -exec sed -i 's/ArchAArch64/ArchARM64/g' '{}' ';'
  sed -i 's/ArchAArch64/ArchARM64/g' src/Gen2/DynamicLinking.hs

  patchShebangs .
  ./utils/makePackages.sh copy
''
