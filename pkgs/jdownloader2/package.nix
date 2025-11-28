{
  pkgs,
  fetchurl,
  makeWrapper,
  jre,
  inputs
}:
with pkgs;
stdenv.mkDerivation rec {
  # name of our derivation
  name = "jdownloader2";
  dontUnpack = true;

  # sources that will be used for our derivation.
  src = inputs.jdownloader;

  meta.mainProgram = "jdownloader2";

  nativeBuildInputs = [ makeWrapper ];

  desktopFile = makeDesktopItem {
    name = name;
    desktopName = "JDownloader";
    comment = "JDownloader download manager";
    categories = [
      "Network"
      "FileTransfer"
      "Graphics"
      "Utility"
    ];
    icon = fetchurl {
      url = "https://aur.archlinux.org/cgit/aur.git/plain/jdownloader256.png?h=jdownloader2";
      hash = "sha256-bHoo7HLIYn6b8GpY1/a/7QdWMqZ0PhyAh9wPoGUmFQQ=";
    };
    exec = "${startScript}/bin/${name} %f";
    terminal = false;
  };

  startScript = writeShellApplication {
    name = name;
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
          #ln -fs ${src} JDownloader.jar
          cp ${src} JDownloader.jar
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
    install ${src} $out/share/java/jdownloader2/JDownloader.jar
    mkdir -p $out/bin

    install ${startScript}/bin/${name} $out/bin/jdownloader2

    chmod 777 $out/share/java/jdownloader2/JDownloader.jar
    chmod +x $out/bin/jdownloader2

    mkdir -p $out/share/applications
    install ${desktopFile}/share/applications/${name}.desktop $out/share/applications/${name}.desktop
  '';

} 