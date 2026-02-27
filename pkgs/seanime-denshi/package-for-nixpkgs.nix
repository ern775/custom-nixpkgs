{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
  stdenvNoCC,
  undmg,
}:
let
  pname = "seanime-denshi";
  version = "3.5.1";

  srcs = rec {
    x86_64-linux = fetchurl {
      url = "https://github.com/5rahim/seanime/releases/download/v${version}/seanime-denshi-${version}_Linux_x86_64.AppImage";
      hash = "sha256-W2UpA9OYTv53cTvhlS/gJsWysywqv+NYzG9W4qv8Ztg=";
    };
    aarch64-linux = x86_64-linux;
    aarch64-darwin = fetchurl {
      url = "https://github.com/5rahim/seanime/releases/download/v${version}/seanime-denshi-${version}_MacOS_arm64.dmg";
      hash = "sha256-NJ20OmM8ejSTwj5O5aD0xTP+QDCVxFxIGdJNZq7KUPI=";
    };
  };

  src =
    srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  meta = {
    description = "Electron-based desktop client for Seanime.";
    homepage = "https://seanime.app";
    changelog = "https://github.com/5rahim/seanime/blob/main/CHANGELOG.md";
    mainProgram = "seanime-denshi";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ern775 ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
in
if stdenv.hostPlatform.isDarwin then
  stdenvNoCC.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [ undmg ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/Applications
      cp -r Seanime\ Denshi.app $out/Applications
      ln -s "$out/Applications/Seanime\ Denshi.app/Contents/MacOS/Seanime\ Denshi" "$out/bin/seanime-denshi"

      runHook postInstall
    '';
  }
else
  appimageTools.wrapType2 {
    inherit
      pname
      version
      src
      meta
      ;

    extraInstallCommands =
      let
        contents = appimageTools.extract { inherit pname version src; };
      in
      ''
        install -Dm644 ${contents}/seanime-denshi.desktop $out/share/applications/seanime-denshi.desktop
        substituteInPlace $out/share/applications/seanime-denshi.desktop \
          --replace-fail 'AppRun' 'seanime-denshi'
        cp -r ${contents}/usr/share/icons $out/share
      '';
  }
