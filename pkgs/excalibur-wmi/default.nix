{
  source,
  stdenv,
  lib,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "excalibur-wmi";

  inherit (source) date src;
  version = "0-unstable-${finalAttrs.date}";

  setSourceRoot = ''
    export sourceRoot=$(pwd)/source
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(sourceRoot)"
  ];

  enableParallelBuilding = true;

  buildFlags = [ "modules" ];

  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];

  installTargets = [ "modules_install" ];

  meta = {
    description = "Casper Excalibur G770 (10th generation) Linux WMI Driver";
    homepage = "https://github.com/betelqeyza/excalibur-wmi";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ern775 ];
    mainProgram = "excalibur-wmi";
    platforms = lib.platforms.linux;
  };
})