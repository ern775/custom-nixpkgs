{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "excalibur-wmi";
  version = "unstable-2025-05-22";

  src = fetchFromGitHub {
    owner = "betelqeyza";
    repo = "excalibur-wmi";
    rev = "67b41f503511d336105088c0bc5c0b796273019e";
    hash = "sha256-jgMapWJ8CtesENuGSSC8s10+ojUHlyc/lsQ1wj0y2LM=";
  };

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
    homepage = "https://github.com/betelqeyza/excalibur-wmi/tree/new";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ern775 ];
    mainProgram = "excalibur-wmi";
    platforms = lib.platforms.linux;
  };
})