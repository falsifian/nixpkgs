{stdenv, fetchurl, unzip, xlibs, libjpeg}:

stdenv.mkDerivation rec {
  name = "jasper-1.900.1";

  src = fetchurl {
    # Maybe vulnerable to CVE-2014-9029.
    url = "VULNERABLE_http://www.ece.uvic.ca/~mdadams/jasper/software/${name}.zip";
    # sha256 = "154l7zk7yh3v8l2l6zm5s2alvd2fzkp6c9i18iajfbna5af5m43b";
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  patches = [
    ./jasper-CVE-2014-8137-variant2.diff ./jasper-CVE-2014-8137-noabort.diff
    ./jasper-CVE-2014-8138.diff
    ./jasper-CVE-2014-9029.diff
  ];

  nativeBuildInputs = [unzip];
  propagatedBuildInputs = [ libjpeg ];

  configureFlags = "--enable-shared";
  
  meta = {
    homepage = https://www.ece.uvic.ca/~frodo/jasper/;
    description = "JPEG2000 Library";
  };
}
