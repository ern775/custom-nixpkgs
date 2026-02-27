{
  lib,
  source,
  buildGoModule,
  buildNpmPackage,
  ffmpeg,
  makeDesktopItem,
  copyDesktopItems,
  callPackage,

  # we use the same electron as upstream
  denshi-electron ? callPackage ./electron.nix { },
}:
let
  inherit (source) src;
  version = lib.replaceStrings [ "v" ] [ "" ] source.version;

  seanime-web =
    {
      npmBuildScript ? "build",
      installPhase ? ''
        runHook preInstall

        mkdir -p $out
        cp -r out $out/web

        runHook postInstall
      '',
    }:
    buildNpmPackage {
      pname = "seanime-web";

      inherit
        src
        version
        npmBuildScript
        installPhase
        ;

      sourceRoot = "${src.name}/seanime-web";

      patches = [ ./default-disable-update-check.patch ];

      npmDepsHash = "sha256-Pelq65U76IvEUIg1VPM4/+2zAOBk2QUositZMZPYjm8=";
    };
in
buildGoModule (finalAttrs: {
  pname = "seanime";

  inherit src version;

  vendorHash = "sha256-TN9shH4B7XVDIa541+7MHTNQs1IKPRJW1dn8tmES5jg=";

  preBuild = ''
    cp -r ${seanime-web { }}/web .

    # .github scripts redeclare main
    rm -rf .github
  '';

  subPackages = [ "." ];

  doCheck = false; # broken in clean environments

  ldflags = [
    "-s"
    "-w"
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        ffmpeg
      ]
    }"
  ];

  passthru.denshi = buildNpmPackage {
    pname = "seanime-denshi";

    inherit src version;

    sourceRoot = "${src.name}/seanime-denshi";

    npmDepsHash = "sha256-KVQKo8iXhuOzIb2wpR0RPXiwanP6hCUu4cH1kUOKMnM=";

    nativeBuildInputs = [
      copyDesktopItems
    ];

    patches = [ ./fix-paths.patch ];

    postPatch = ''
      substituteInPlace src/main.js --replace-fail SEANIME ${lib.getExe finalAttrs.finalPackage}
    '';

    preBuild = ''
      cp -r ${
        seanime-web {
          npmBuildScript = "build:denshi";
          installPhase = ''
            runHook preInstall

            mkdir -p $out
            cp -r out-denshi $out/web-denshi

            runHook postInstall
          '';
        }
      }/web-denshi .
    '';

    env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

    npmRebuildFlags = [ "--ignore-scripts" ];

    buildPhase = ''
      runHook preBuild

      npm exec electron-builder -- \
        --dir \
        -c.electronDist=${denshi-electron.dist} \
        -c.electronVersion=${denshi-electron.version} \
        -c.extraMetadata.version=v${finalAttrs.version}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/seanime-denshi
      cp -r dist/linux-unpacked/{locales,resources{,.pak}} $out/share/seanime-denshi

      makeWrapper ${lib.getExe denshi-electron} $out/bin/seanime-denshi \
        --add-flags $out/share/seanime-denshi/resources/app.asar \
        --inherit-argv0

      for size in 16 18 24 32 48 64 128 256 512 1024; do
        install -Dm644 "assets/"$size"x"$size".png" "$out/share/icons/hicolor/"$size"x"$size"/apps/seanime-denshi.png"
      done

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        name = "seanime-denshi";
        type = "Application";
        desktopName = "Seanime Denshi";
        comment = "Desktop client for Seanime.";
        icon = "seanime-denshi";
        exec = "seanime-denshi";
        categories = [
          "AudioVideo"
          "Player"
          "Video"
        ];
      })
    ];
  };

  meta = {
    description = "Open-source media server for anime and manga";
    homepage = "https://seanime.app";
    changelog = "https://github.com/5rahim/seanime/blob/main/CHANGELOG.md";
    mainProgram = "seanime";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [
      ern775
      thegu5
    ];
  };
})
