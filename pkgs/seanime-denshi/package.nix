{
  lib,
  source,
  appimageTools,
  makeWrapper,
}:
appimageTools.wrapType2 rec {
  pname = "seanime-denshi";

  inherit (source) version src;

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands =
    let
      contents = appimageTools.extract { inherit pname version src; };
    in
    ''
      # the custom electron used by upstream seems to not respect "auto", therefore we use "wayland"
      wrapProgram $out/bin/${pname} \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

      install -Dm644 ${contents}/seanime-denshi.desktop $out/share/applications/seanime-denshi.desktop
      substituteInPlace $out/share/applications/seanime-denshi.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=seanime-denshi'

      # the 439x439 directory doesn't get picked up for some reason
      mkdir -p $out/share/icons/hicolor
      cp -r ${contents}/usr/share/icons/hicolor/439x439 $out/share/icons/hicolor/512x512
    '';

  meta = {
    description = "Electron-based desktop client for Seanime.";
    homepage = "https://seanime.app";
    changelog = "https://github.com/5rahim/seanime/blob/main/CHANGELOG.md";
    mainProgram = "seanime-denshi";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ern775 ];
    platforms = [
      "x86_64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
