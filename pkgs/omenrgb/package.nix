{
  source,
  lib,
  stdenv,
  gcc,
  wxGTK32,
  coreutils,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "omenrgb";

  inherit (source) date src;
  version = "0-unstable-${finalAttrs.date}";

  postPatch = ''
    substituteInPlace ./backlight.rules \
      --replace-fail '/bin/chmod' '${coreutils}/bin/chmod'
  '';

  nativeBuildInputs = [
    wrapGAppsHook3
  ];

  buildInputs = [
    gcc
    wxGTK32
  ];

  buildPhase = ''
    runHook preBuild
    bash ./build.sh
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp omenrgb $out/bin/omenrgb
    runHook postInstall
  '';

  postInstall = ''
    mkdir -p $out/etc/udev/rules.d
    cp backlight.rules $out/etc/udev/rules.d/81-backlight.rules
  '';

  meta = with lib; {
    description = "GUI for controlling RGB lighting on OMEN laptops for Linux";
    homepage = "https://github.com/lemogne/omenrgb";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ern775 ];
    mainProgram = "omenrgb";
    platforms = platforms.all;
  };
})
