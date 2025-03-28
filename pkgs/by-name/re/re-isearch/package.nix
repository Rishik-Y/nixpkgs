{
  stdenv,
  fetchFromGitHub,
  lib,
  db,
  file,
  libnsl,
}:

stdenv.mkDerivation (finalAttr: {
  pname = "re-Isearch";
  version = "2.20220925.4.0a";

  src = fetchFromGitHub {
    owner = "re-Isearch";
    repo = "re-Isearch";
    tag = "e5953ea6c84285283be3689df7065908369cdbaf";
    sha256 = "sha256-D0PDqlWzIOHqdS2MlNzR2T5cyhiLcFlf30v6eFokoRQ=";
  };

  postPatch = ''
    # Fix gcc-13 build due to missing <cstdint> include.
    sed -e '1i #include <cstdint>' -i src/mmap.cxx
  '';

  buildinputs = [
    db
    file # libmagic
    libnsl
  ];

  makeFlags = [
    "CC=g++"
    "cc=gcc"
    "LD=g++"
    "INSTALL=${placeholder "out"}/bin"
  ];

  preBuild = ''
    cd build
    makeFlagsArray+=(
      EXTRA_INC="-I${db.dev}/include -I${lib.getDev file}/include"
      LD_PATH="-L../lib -L${db.out}/lib -L${file}/lib -L${libnsl}/lib"
    )
  '';

  preInstall = ''
    mkdir -p $out/{bin,lib}
  '';
  postInstall = ''
    cp ../lib/*.so $out/lib/
  '';

  meta = {
    description = "Novel multimodal search and retrieval engine";
    homepage = "https://github.com/re-Isearch/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.astro ] ++ lib.teams.ngi.members;
  };
})
