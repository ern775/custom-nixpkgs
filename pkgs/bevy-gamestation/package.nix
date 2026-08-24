{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libxkbcommon,
  udev,
  vulkan-loader,
  stdenv,
  alsa-lib,
  wayland,
  nix-update-script,
  makeWrapper,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bevy-gamestation";
  version = "0-unstable-2026-05-19";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Hakkology";
    repo = "Bevy-Gamestation";
    rev = "c74ec0ed3954bdc80e1ea92ed9b72a650742d533";
    hash = "sha256-x7ihaP25OQ5fnx+LsQA0qfBZSJpfLCphoTpENHc54Ys=";
  };

  cargoLock = {
    lockFile = "${finalAttrs.src}/Cargo.lock";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    makeWrapper
  ];

  buildInputs = [
    libxkbcommon
    udev
    vulkan-loader
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    wayland
  ];

  runtimeDeps = [
    vulkan-loader
    libxkbcommon
  ];

  postInstall = ''
    wrapProgram "$out/bin/gamestation" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.runtimeDeps}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "";
    homepage = "https://github.com/Hakkology/Bevy-Gamestation";
    license = lib.licenses.MIT;
    maintainers = with lib.maintainers; [ ern775 ];
    mainProgram = "gamestation";
  };
})
