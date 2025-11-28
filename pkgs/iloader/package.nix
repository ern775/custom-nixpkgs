{
  lib,
  stdenv,
  fetchurl,
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
  version = "v1.1.2";

  src = fetchurl {
    url = "https://github.com/nab138/iloader/releases/download/${finalAttrs.version}/iloader-linux-amd64.deb";
    hash = "sha256-D4lnljb8tk1FlJRlkda6XoiPPFTKw6YxdRUZ5Ltf35A=";
  };

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
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ ern775 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "iloader";
  };
})
