{
  source,
  stdenv,
  lib,
  meson,
  ninja,
  pkg-config,
  glib,
  gtk4,
  wrapGAppsHook4,
  desktop-file-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "victus-control";

  inherit (source) date src;
  version = "0-unstable-${finalAttrs.date}";

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    desktop-file-utils
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
  ];

  installPhase = ''
    runHook preInstall
    pwd 
    install -Dm755 "backend/victus-backend" "$out/bin/victus-backend"
    install -Dm755 "frontend/victus-control" "$out/bin/victus-control"
    install -Dm644 "$src/frontend/victus-icon.svg" "$out/share/icons/hicolor/48x48/apps/victus-icon.svg"
    install -Dm644 "$src/frontend/victus-control.desktop" "$out/share/applications/victus-control.desktop"
    install -Dm444 $src/backend/victus-backend.service $out/lib/systemd/system/victus-backend.service
    for f in "$out/lib/systemd/system/"*.service "$out/share/applications/"*.desktop; do
      substituteInPlace "$f" \
        --replace "/usr/bin" "$out/bin"
    done
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://github.com/Vilez0/victus-control";
    description = "Victus Control";
    mainProgram = "victus-control";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
})
