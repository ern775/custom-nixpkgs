{
  source,
  stdenv,
  lib,
  xz,
  renameInternalName ? true,
}:

let
  # Used to set folder name of tool
  folderName = "DW-Proton";
  # Used to set display name of tool in Steam
  steamName = "DW-Proton";

in
stdenv.mkDerivation {
  pname = folderName;
  version = lib.removePrefix "dwproton-" source.version;

  inherit (source) src;

  nativeBuildInputs = [ xz ];
  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    # Create the steamcompat directory
    mkdir -p $steamcompattool
    cp -r ./* $steamcompattool/

    # Modify the display name
    sed -i -r "s|\"display_name\".*|\"display_name\" \"${steamName}\"|" \
      $steamcompattool/compatibilitytool.vdf

    ${lib.optionalString renameInternalName ''
      sed -i -r 's|"dw-proton-[^"]*"(\s*// Internal name)|"${steamName}"\1|' $steamcompattool/compatibilitytool.vdf
    ''}

    # Create a real folder so that Steam doesn't require reselecting compatibility tool on update
    mkdir -p $out/share/Steam/compatibilitytools.d/${folderName}

    #Symlink the files INSIDE, not the folder itself. Oopsie
    ln -s $steamcompattool/* $out/share/Steam/compatibilitytools.d/${folderName}/

    runHook postInstall
  '';

  meta = with lib; {
    description = ''
      DW-Proton compatibility layer.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://dawn.wine/dawn-winery/dwproton";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with lib.maintainers; [ ern775 ];
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
  };
}
