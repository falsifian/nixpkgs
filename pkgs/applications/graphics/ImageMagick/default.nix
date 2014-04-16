{ stdenv
, fetchurl
, pkgconfig
, bzip2
, fontconfig
, freetype
, ghostscript ? null
, libjpeg
, libpng
, libtiff
, libxml2
, zlib
, libtool
, jasper
, libX11
, tetex ? null
, librsvg ? null
}:

let
  version = "6.8.8-7";
in
stdenv.mkDerivation rec {
  name = "ImageMagick-${version}";

  src = fetchurl {
    url = "mirror://imagemagick/${name}.tar.xz_VULNERABLE";  # CVE-2014-{1947,1958,2030}.  See https://bugzilla.redhat.com/show_bug.cgi?id=1064098 .  Based on that and on http://www.imagemagick.org/script/changelog.php and on https://bugzilla.redhat.com/show_bug.cgi?id=1067276 , it looks like they are fixed in ImageMagick 6.8.9-0.
    sha256 = "1x5jkbrlc10rx7vm344j7xrs74c80xk3n1akqx8w5c194fj56mza";
  };

  enableParallelBuilding = true;

  preConfigure = if tetex != null then
    ''
      export DVIDecodeDelegate=${tetex}/bin/dvips
    '' else "";

  configureFlags = "" + stdenv.lib.optionalString (stdenv.system != "x86_64-darwin") ''
    --with-gs-font-dir=${ghostscript}/share/ghostscript/fonts
    --with-gslib
  '' + ''
    --with-frozenpaths
    ${if librsvg != null then "--with-rsvg" else ""}
  '';

  propagatedBuildInputs =
    [ bzip2 fontconfig freetype libjpeg libpng libtiff libxml2 zlib librsvg
      libtool jasper libX11
    ] ++ stdenv.lib.optional (stdenv.system != "x86_64-darwin") ghostscript;

  buildInputs = [ tetex pkgconfig ];

  postInstall = ''(cd "$out/include" && ln -s ImageMagick* ImageMagick)'';

  meta = with stdenv.lib; {
    homepage = http://www.imagemagick.org/;
    description = "A software suite to create, edit, compose, or convert bitmap images";
    platforms = platforms.linux ++ [ "x86_64-darwin" ];
    maintainers = with maintainers; [ the-kenny ];
  };
}
