{
  source,
  stdenv,
  lib,
  xz,
  variant,
  renameInternalName ? true,
}:

let
  # Used to set folder name of tool
  folderName = if variant == "base" then "proton-cachyos" else "proton-cachyos-${variant}";
  # Used to set display name of tool in Steam
  steamName = if variant == "base" then "Proton CachyOS" else "Proton CachyOS ${variant}";

in
stdenv.mkDerivation {
  pname = folderName;
  version = lib.removePrefix "cachyos-" source.version;

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
      sed -i -r 's|"proton-cachyos-[^"]*"(\s*// Internal name)|"${steamName}"\1|' $steamcompattool/compatibilitytool.vdf
    ''}

    # Create a real folder so that Steam doesn't require reselecting compatibility tool on update
    mkdir -p $out/share/Steam/compatibilitytools.d/${folderName}

    #Symlink the files INSIDE, not the folder itself. Oopsie
    ln -s $steamcompattool/* $out/share/Steam/compatibilitytools.d/${folderName}/

    runHook postInstall
  '';

  meta = with lib; {
    description = "${steamName}";
    homepage = "https://github.com/CachyOS/proton-cachyos";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
  };
}