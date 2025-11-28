{
  lib,
  fetchzip,
  stdenvNoCC,
  writeScript,
  # Can be overridden to alter the display name in steam
  # This could be useful if multiple versions should be installed together
  steamDisplayName ? "Proton-Spritz",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-spritz";
  version = "spritz-cachyos-10.0-20251006-slr";

  src = fetchzip {
    url = "https://github.com/NelloKudo/proton-cachyos/releases/download/${finalAttrs.version}/proton-${finalAttrs.version}-x86_64_v3.tar.xz";
    hash = "sha256-sg84xz2rTAIvt4KkYFYhUqtp+lCh5HKPIfRz2+VTQlM=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    # Also leave some breadcrumbs in the file.
    echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

    mkdir $steamcompattool
    ln -s $src/* $steamcompattool
    rm $steamcompattool/compatibilitytool.vdf
    cp $src/compatibilitytool.vdf $steamcompattool

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
      --replace-fail "proton-${finalAttrs.version}-x86_64_v3" "${steamDisplayName}"
  '';

  passthru.updateScript = writeScript "update-proton-spritz" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p curl jq common-updater-scripts
    repo="https://api.github.com/repos/NelloKudo/proton-cachyos/releases"
    version="$(curl -sL "$repo" | jq 'map(select(.prerelease == false)) | .[0].tag_name' --raw-output)"
    update-source-version proton-spritz-bin "$version"
  '';

  meta = {
    description = ''
      Compatibility tool for Steam Play based on Wine and additional components with added patches for certain anime games.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/NelloKudo/proton-cachyos";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [
      ern775
    ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
