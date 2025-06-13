{
  pkg-config,
  clang,
  clang-tools,
  meson,
  ninja,
  gtest,
  mkShellNoCC,
}:

mkShellNoCC {
  hardeningDisable = ["all"];

  nativeBuildInputs = [
    pkg-config
    clang
    clang-tools
    meson
    ninja
  ];

  buildInputs = [
    gtest
  ];

  shellHook = ''
    ln -sf build/compile_commands.json
  '';
}
