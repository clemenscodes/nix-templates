{
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
  clang,
  gtest,
  pname,
  src,
  version,
}:
stdenv.mkDerivation {
  inherit pname version src;

  hardeningDisable = ["all"];

  nativeBuildInputs = [
    pkg-config
    ninja
    meson
    clang
  ];

  buildInputs = [
    gtest
  ];

  doCheck = true;

  meta = {
    description = "Hello world using Meson and C++";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
