{ stdenv, fetchurl, nasm }:

stdenv.mkDerivation rec {
  name = "libjpeg-turbo-1.3.0";

  src = fetchurl {
    url = "mirror://sourceforge/libjpeg-turbo/${name}.tar.gz_vulnerable_through_1.3.0";
    #sha256 = "0d0jwdmj3h89bxdxlwrys2mw18mqcj4rzgb5l2ndpah8zj600mr6";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  patches = [ ./libjpeg-turbo-1.3.0-CVE-2013-6629-and-6630.patch ];

  buildInputs = [ nasm ];

  doCheck = true;
  checkTarget = "test";

  meta = {
    homepage = http://libjpeg-turbo.virtualgl.org/;
    description = "A faster (using SIMD) libjpeg implementation";
    license = "free";
  };
}
