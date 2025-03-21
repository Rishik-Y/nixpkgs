{
  lib,
  stdenv,
  fetchFromGitHub,
  jre,
  makeWrapper,
  maven,
  libGL,
  xdg-utils,
  libXxf86vm,
  zip,
  zlib,
}:
maven.buildMavenPackage rec {
  pname = "polyglot";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "DraqueT";
    repo = "PolyGlot";
    tag = "v${version}";
    hash = "sha256-jDW74Hk+6vzCUm84wwMn5XBGPVlsJ3mQrjtuqMZssz0=";
  };

  preBuild = ''
    echo "${version}" > assets/assets/org/DarisaDesigns/version
    cd docs
    zip -r ../assets/assets/org/DarisaDesigns/readme *
    cd ../packaging_files/example_lexicons
    zip -r ../../assets/assets/org/DarisaDesigns/exlex *
    cd ../..
  '';

  mvnHash =
    {
      aarch64-linux = "sha256-Tlz2I6xE8g3GqKz9N7VXRO0ObE1XOv6IfTrKZmVlscY=";
      x86_64-linux = "sha256-nQScNCkA+eaeL3tcLCec1qIoYO6ct28FLxGp/Cm4nn4=";
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  mvnParameters = "-DskipTests";

  nativeBuildInputs = [
    makeWrapper
    zip
  ];
  runtimeDeps = [
    xdg-utils
    zlib
  ];
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/PolyGlotLinA
    install -Dm644 --target-directory=$out/share/PolyGlotLinA target/PolyGlotLinA-${version}-jar-with-dependencies.jar

    makeWrapper ${jre}/bin/java $out/bin/PolyGlot \
      --add-flags "-Djpackage.app-version=${version}" \
      --add-flags "-jar $out/share/PolyGlotLinA/PolyGlotLinA-${version}-jar-with-dependencies.jar" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libGL
          libXxf86vm
        ]
      }"

    runHook postInstall
  '';

  meta = {
    description = "Conlang construction toolkit";
    homepage = "https://draquet.github.io/PolyGlot/readme.html";
    changelog = "https://github.com/DraqueT/PolyGlot/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ noodlez1232 ];
    platforms = lib.platforms.linux;
    mainProgram = "PolyGlot";
  };
}
