{ stdenv, fetchurl
, openssl, readline, ncurses, zlib }:

let
  os = if stdenv.isLinux then "1"
       else if stdenv.isFreeBSD then "2"
       else if stdenv.isSunOS then "3"
       else if stdenv.isDarwin then "4"
       else if stdenv.isOpenBSD then "5"
       else "";
  cpuBits = if stdenv.is64bit then "2" else "1";

in

stdenv.mkDerivation rec {
  name = "softether-${version}";
  version = "4.20";
  build = "9608";
  compiledDate = "2016.04.17";
  dataDir = "/var/lib/softether";

  src = fetchurl {
    url = "http://www.softether-download.com/files/softether/v${version}-${build}-rtm-${compiledDate}-tree/Source_Code/softether-src-v${version}-${build}-rtm.tar.gz";
    sha256 = "e559644e34ec6feba43d99f4083f77f9b082dd0574d0bb1e416a65f32ccbc51e";
  };

  buildInputs = [ openssl readline ncurses zlib ];

  preConfigure = ''
      echo "${os}
      ${cpuBits}
      " | ./configure
      rm configure
  '';

  buildPhase = ''
      mkdir -p $out/bin
      sed -i \
          -e "/INSTALL_BINDIR=/s|/usr/bin|/bin|g" \
          -e "/_DIR=/s|/usr|${dataDir}|g" \
          -e "s|\$(INSTALL|$out/\$(INSTALL|g" \
          -e "/echo/s|echo $out/|echo |g" \
          Makefile
  '';

  meta = with stdenv.lib; {
    description = "An Open-Source Free Cross-platform Multi-protocol VPN Program";
    homepage = https://www.softether.org/;
    license = licenses.gpl2;
    maintainers = [ maintainers.rick68 ];
    platforms = platforms.linux;
  };
}
