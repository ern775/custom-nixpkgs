{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  electron_39,
  libgcc,
}:
buildNpmPackage (finalAttrs: {
  pname = "dopamine";
  version = "3.0.4";

  src = fetchFromGitHub {
    owner = "digimezzo";
    repo = "dopamine";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/qgzlbaV0JdKD3UT9Kr5QD3RPMF0ZvO3VIdHokGAFic=";
  };

  # patches = [ ./remove-register-scheme.patch ];
  nativeBuildInputs = [ libgcc ];
  buildInputs = [ libgcc ];

  runtimeDeps = [ libgcc ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  forceGitDeps = true;
  npmDepsHash = "sha256-45e2l9/sGywm9UeVhMSWcerrR/JxiZVODxifRuBVYr8=";

  buildPhase = ''
    runHook preBuild

    npm run build:prod
    npm exec electron-builder -- \
      --dir \
      -c.electronDist=${electron_39.dist} \
      -c.electronVersion=${electron_39.version} \
      -c.extraMetadata.version=v${finalAttrs.version} \
      --config electron-builder.config.js

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ${
      if stdenv.hostPlatform.isDarwin then
        ''
          mkdir -p $out/{Applications,bin}
          cp -r dist/mac*/Dopamine.app $out/Applications
          makeWrapper $out/Applications/Dopamine.app/Contents/MacOS/Dopamine $out/bin/dopamine
        ''
      else
        ''
          mkdir -p $out/share/dopamine
          cp -r release/linux-unpacked/{locales,resources{,.pak}} $out/share/dopamine

          makeWrapper ${lib.getExe electron_39} $out/bin/dopamine \
            --add-flags $out/share/dopamine/resources/app.asar \
            --inherit-argv0

          for size in 16 24 32 48 64 96 128 256 512; do
            install -Dm644 "build/icons/"$size"x"$size".png" "$out/share/icons/hicolor/"$size"x"$size"/apps/dopamine.png"
          done
        ''
    }

    runHook postInstall
  '';

  meta = {
    description = "The audio player that keeps it simple";
    homepage = "https://github.com/digimezzo/dopamine";
    changelog = "https://github.com/digimezzo/dopamine/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "dopamine";
    platforms = lib.platforms.all;
  };
})
