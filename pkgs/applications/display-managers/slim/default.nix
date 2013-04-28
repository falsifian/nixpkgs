{ stdenv, fetchurl, cmake, pkgconfig, x11, libjpeg, libpng12, libXmu
, fontconfig, freetype, pam, dbus_libs }:

stdenv.mkDerivation rec {
  name = "slim-1.3.5";

  src = fetchurl {
    url = "http://download.berlios.de/slim/${name}.tar.gz";
    sha256 = "0aanclmm7ac3h1pxd5p78n5y8ns1ly8cwxggjidqvyp2a6gj13c1";
  };

  patches = [
    # Allow the paths of the configuration file and theme directory to
    # be set at runtime.
    ./runtime-paths.patch
  ];

  buildInputs =
    [ cmake pkgconfig x11 libjpeg libpng12 libXmu fontconfig freetype
      pam dbus_libs
    ];

  preConfigure = "substituteInPlace CMakeLists.txt --replace /etc $out/etc";

  cmakeFlags = [ "-DUSE_PAM=1" ];

  NIX_CFLAGS_LINK = "-lXmu";

  meta = {
    homepage = http://slim.berlios.de;
    platforms = stdenv.lib.platforms.linux;
  };
}
