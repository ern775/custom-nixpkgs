{
  source,
  lib,
  stdenv,
  dpkg,
  autoPatchelfHook,
  glib,
  gtk3,
  wrapGAppsHook3,
  webkitgtk_4_1,
  gdk-pixbuf,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "iloader";

  inherit (source) version src;

  unpackCmd = "dpkg -x $curSrc source";

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    webkitgtk_4_1
    gdk-pixbuf
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv usr/share usr/bin $out

    runHook postInstall
  '';

  meta = {
    description = "User friendly sideloader";
    homepage = "https://github.com/nab138/iloader";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ern775 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "iloader";
  };
})
