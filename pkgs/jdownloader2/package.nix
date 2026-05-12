{
  source,
  lib,
  stdenv,
  makeDesktopItem,
  writeShellApplication,
  fetchurl,
  makeWrapper,
  jre,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "jdownloader2";
  dontUnpack = true;

  inherit (source) version src;

  nativeBuildInputs = [ makeWrapper ];

  desktopFile = makeDesktopItem {
    name = finalAttrs.pname;
    desktopName = "JDownloader";
    comment = "JDownloader download manager";
    categories = [
      "Network"
      "FileTransfer"
      "Utility"
    ];
    icon = fetchurl {
      url = "https://jdownloader.org/_media/knowledge/wiki/jdownloader.png";
      hash = "sha256-Prq5kufdBP/LbDD+4afitD81N8srIhJLMDJdJb/9rCk=";
    };
    exec = "${finalAttrs.startScript}/bin/${finalAttrs.pname} %f";
    terminal = false;
  };

  startScript = writeShellApplication {
    name = finalAttrs.pname;
    text = ''
      function isRoot() {
      	if [ "$(id -u)" -eq "0" ]; then
      		return 0
      	fi
      	return 2
      }

      function changePath() {
      	if isRoot ; then
      		export JD_SCOPE="global"
      		echo "[global JDownloader scope]"
      		umask u=rwx,g=rwx,o=rx
      		cd '/var/lib/JDownloader'
      	else
      		export JD_SCOPE="user"
      		echo "[user JDownloader scope]"
      		mkdir -p "''${HOME}/.jd"
      		cd "''${HOME}/.jd"
      	fi
      }

      function downloadJDownloader() {
      	changePath
      	if [ ! -f "JDownloader.jar" ]; then
          #ln -fs ${finalAttrs.src} JDownloader.jar
          cp ${finalAttrs.src} JDownloader.jar
      	fi
        chmod 777 JDownloader.jar
      }

      changePath
      downloadJDownloader

      exec ${jre}/bin/java -jar JDownloader.jar "$@"
    '';
  };

  installPhase = ''
    mkdir -p $out/share/java/jdownloader2
    install ${finalAttrs.src} $out/share/java/jdownloader2/JDownloader.jar
    mkdir -p $out/bin

    install ${finalAttrs.startScript}/bin/${finalAttrs.pname} $out/bin/jdownloader2

    chmod 777 $out/share/java/jdownloader2/JDownloader.jar
    chmod +x $out/bin/jdownloader2

    mkdir -p $out/share/applications
    install ${finalAttrs.desktopFile}/share/applications/${finalAttrs.pname}.desktop $out/share/applications/${finalAttrs.pname}.desktop
  '';

  meta = {
    description = "Download Manager";
    homepage = "https://jdownloader.org/";
    maintainers = with lib.maintainers; [ ern775 ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "jdownloader2";
  };
})
