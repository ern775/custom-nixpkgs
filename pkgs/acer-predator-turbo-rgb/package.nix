{
  source,
  stdenv,
  lib,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "acer-predator-turbo-rgb";

  inherit (source) date src;
  version = "0-unstable-${finalAttrs.date}";

  setSourceRoot = ''
    export sourceRoot=$(pwd)/source
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(sourceRoot)"
  ];

  enableParallelBuilding = true;

  buildFlags = [ "modules" ];

  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];

  installTargets = [ "modules_install" ];

  installPhase = ''
    runHook preInstall
    install -D -t $out/lib/modules/${kernel.modDirVersion}/extra src/facer.ko
    runHook postInstall
  '';

  meta = with lib; {
    description = "GUI for controlling acer-predator-turbo-and-rgb-keyboard-linux-module";
    homepage = "https://github.com/JafarAkhondali/acer-predator-turbo-and-rgb-keyboard-linux-module";
    license = licenses.gpl3Only;
    maintainers = [ Ern775 ];
    platforms = platforms.linux;
  };
})
