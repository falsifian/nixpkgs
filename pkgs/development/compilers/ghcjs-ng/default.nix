{ stdenv
, pkgsHostHost
, callPackage
, fetchgit
, ghcjsSrcJson ? null
, ghcjsSrc ? fetchgit (builtins.fromJSON (builtins.readFile ghcjsSrcJson))
, bootPkgs
, stage0
, haskellLib
, cabal-install
, emscripten
, nodejs
, makeWrapper
, xorg
, gmp
, pkg-config
, gcc
, lib
, ghcjsDepOverrides ? (_:_:{})
, haskell
}:

let
  passthru = {
    configuredSrc = callPackage ./configured-ghcjs-src.nix {
      inherit ghcjsSrc;
      inherit (bootPkgs) ghc alex happy;
    };
    genStage0 = callPackage ./mk-stage0.nix { inherit (passthru) configuredSrc; };
    bootPkgs = bootPkgs.extend (lib.foldr lib.composeExtensions (_:_:{}) [
      (self: _: import stage0 {
        inherit (passthru) configuredSrc;
        inherit (self) callPackage;
      })

      (callPackage ./common-overrides.nix {
        inherit haskellLib;
      })
      ghcjsDepOverrides
    ]);

    targetPrefix = "";
    inherit bootGhcjs;
    inherit (bootGhcjs) version;
    ghcVersion = bootPkgs.ghc.version;
    isGhcjs = true;

    enableShared = true;

    socket-io = pkgsHostHost.nodePackages."socket.io";

    # Relics of the old GHCJS build system
    stage1Packages = [];
    mkStage2 = { callPackage }: {
      # https://github.com/ghcjs/ghcjs-base/issues/110
      # https://github.com/ghcjs/ghcjs-base/pull/111
      ghcjs-base = haskell.lib.dontCheck (haskell.lib.doJailbreak (callPackage ./ghcjs-base.nix {}));
    };

    haskellCompilerName = "ghcjs-${bootGhcjs.version}";
  };

  bootGhcjs = haskellLib.justStaticExecutables passthru.bootPkgs.ghcjs;

in stdenv.mkDerivation {
    name = bootGhcjs.name;
    src = passthru.configuredSrc;
    nativeBuildInputs = [
      bootGhcjs
      passthru.bootPkgs.ghc
      cabal-install
      nodejs
      makeWrapper
      xorg.lndir
      gmp
      pkg-config
    ] ++ lib.optionals stdenv.isDarwin [
      gcc # https://github.com/ghcjs/ghcjs/issues/663
    ];
    dontConfigure = true;
    dontInstall = true;
    buildPhase = ''
      export HOME=$TMP
      mkdir $HOME/.cabal
      touch $HOME/.cabal/config
      cd lib/boot

      mkdir -p $out/bin
      mkdir -p $out/lib
      lndir ${bootGhcjs}/bin $out/bin

      wrapProgram $out/bin/ghcjs --add-flags "-B$out/lib"
      wrapProgram $out/bin/haddock --add-flags "-B$out/lib"
      wrapProgram $out/bin/ghcjs-pkg --add-flags "--global-package-db=$out/lib/package.conf.d"

      # ghcjs-boot uses its own path, after resolving symlinks, to decide where
      # to put the libraries.
      rm $out/bin/ghcjs-boot
      cp ${bootGhcjs}/bin/ghcjs-boot $out/bin
      env PATH=$out/bin:$PATH $out/bin/ghcjs-boot --with-ghc $out/bin --with-emsdk ${emscripten}
    '';

    inherit passthru;

    meta.platforms = passthru.bootPkgs.ghc.meta.platforms;
    meta.maintainers = [lib.maintainers.elvishjerricco];
  }
