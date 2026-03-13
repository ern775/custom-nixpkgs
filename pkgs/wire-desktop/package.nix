{
  stdenv,
  lib,
  fetchFromGitHub,
  nodejs,
  yarn-berry_3,
  git,
  electron,
  makeWrapper,
  makeDesktopItem,
}:
let
  yarn-berry = yarn-berry_3;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "wire-desktop";
  version = "3.40.3882";

  src = fetchFromGitHub {
    owner = "wireapp";
    repo = "wire-desktop";
    # its literally the same source regardless of platform
    tag = "linux/${finalAttrs.version}";
    hash = "sha256-pNu+/JKvaKSqHxNeDL8RcDy+FiY3aynQH06t05qgXrA=";
  };

  missingHashes = ./missing-hashes.json;
  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes;
    hash = "sha256-md7B8NSqT9dmPxrp9zbWifNow+1j2tuTRMOljG1V8WE=";
  };

  web-config = fetchFromGitHub {
    owner = "wireapp";
    repo = "wire-web-config-wire";
    tag = "v0.34.9-0";
    hash = "sha256-E9x/tRcMfXw/tjgNBUTefym9/m/Xu9/9CclwSmxpDzU=";
  };

  nativeBuildInputs = [
    nodejs
    git
    yarn-berry.yarnBerryConfigHook
    yarn-berry
    makeWrapper
  ];

  postPatch = ''
    substituteInPlace .copyconfigrc.js \
    --replace-fail 'repositoryUrl,' 'repositoryUrl, externalDir : "${finalAttrs.web-config}",'
  '';

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "true";

  buildPhase = ''
    runHook preBuild

  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    cp -R ${electron.dist}/Electron.app Electron.app
    chmod -R u+w Electron.app
  ''
  + ''

    yarn build:ts

    # remove unnecessary folders
    rm -r {bin,jenkins}

    yarn electron-builder \
        --dir \
        ${lib.optionalString stdenv.hostPlatform.isDarwin "--config.mac.identity=null"} \
        -c.electronDist=${if stdenv.hostPlatform.isDarwin then "." else electron.dist} \
        -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/{Applications,bin}
    cp -r dist/mac*/Wire.app $out/Applications

    makeWrapper $out/Applications/Wire.app/Contents/MacOS/wire-desktop $out/bin/wire-desktop
  ''
  + lib.optionalString (stdenv.hostPlatform.linux) ''

    mkdir -p $out/share/wire-desktop
    cp -r dist/*-unpacked/{locales,resources{,.pak}} $out/share/wire-desktop

    makeWrapper ${lib.getExe electron} $out/bin/wire-desktop \
      --add-flags $out/share/wire-desktop/resources/app.asar \
      --inherit-argv0

    for size in 32 256; do
      install -Dm644 "resources/icons/"$size"x"$size".png" "$out/share/icons/hicolor/"$size"x"$size"/apps/wire-desktop.png"
    done
  ''
  + ''

    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    categories = [
      "Network"
      "InstantMessaging"
      "Chat"
      "VideoConference"
    ];
    comment = "Secure messenger for everyone";
    desktopName = "Wire";
    exec = "wire-desktop %U";
    genericName = "Secure messenger";
    icon = "wire-desktop";
    name = "wire-desktop";
    startupWMClass = "Wire";
  };

  meta = {
    description = "Modern, secure messenger for everyone";
    longDescription = ''
      Wire Personal is a secure, privacy-friendly messenger. It combines useful
      and fun features, audited security, and a beautiful, distinct user
      interface.  It does not require a phone number to register and chat.

        * End-to-end encrypted chats, calls, and files
        * Crystal clear voice and video calling
        * File and screen sharing
        * Timed messages and chats
        * Synced across your phone, desktop and tablet
    '';
    homepage = "https://wire.com/";
    downloadPage = "https://wire.com/download/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [
      arianvp
      toonn
      ern775
    ];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
  };
})
