{ stdenv, fetchsvn, kernelHeaders
, installLocales ? true
, profilingLibraries ? false
}:

stdenv.mkDerivation rec {
  name = "eglibc-2.10";

  src = fetchsvn {
    # Maybe vulnerable to:
    # - CVE-2014-5119, or see DSA-3012-1 (or USN-2328-1)
    # - CVE-2012-6656, CVE-2014-6040, CVE-2014-7817, CVE-2015-0235.
    url = "VULNERABLE_svn://svn.eglibc.org/branches/eglibc-2_10";
    rev = 8690;
    sha256 = "0000000000000000000000000000000000000000000000000000";
  };

  inherit kernelHeaders installLocales;

  configureFlags = [
    "--with-headers=${kernelHeaders}/include"
    "--without-fp"
    "--enable-add-ons=libidn,ports,nptl"
    "--disable-profile"
    "--host=arm-linux-gnueabi"
    "--build=arm-linux-gnueabi"
  ];

  builder = ./builder.sh;

  meta = {
    homepage = http://www.gnu.org/software/libc/;
    description = "The GNU C Library";
  };
}
