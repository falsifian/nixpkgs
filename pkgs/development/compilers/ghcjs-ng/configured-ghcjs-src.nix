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
  mkdir -p ghc/compiler/vectorise
  mkdir -p ghc/utils/haddock/haddock-library/vendor

  # Remove version constraints we can't currently satisfy.
  sed -i -e 's/aeson          >= 1.4      && < 1.5,/aeson,/' -e 's/base64-bytestring          >= 1.0 && < 1.1,/base64-bytestring,/' -e 's/wai-extra            >= 3.0  &&  < 3.1,/wai-extra,/' ghcjs.cabal
  # Add a missing version constraint. Fixes an error in test/TestRunner.hs: the
  # ShowHelpText constructor takes an argument in optparse-applicative 0.16.*.
  sed -i -e 's/optparse-applicative,/optparse-applicative >= 0.14 \&\& < 0.16,/' ghcjs.cabal

  patchShebangs .
  ./utils/makePackages.sh copy
''
