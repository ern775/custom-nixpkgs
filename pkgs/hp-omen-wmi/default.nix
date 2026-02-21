{
  source,
  stdenv,
  lib,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hp-omen-wmi";

  inherit (source) date src;
  version = "0-unstable-${finalAttrs.date}";

  setSourceRoot = ''
    export sourceRoot=$(pwd)/source/src
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

  meta = with lib; {
    description = "Linux kernel module for HP Omen Keyboards";
    homepage = "https://github.com/ranisalt/hp-omen-linux-module";
    license = licenses.gpl2;
    maintainers = with maintainers; [ ern775 ];
    platforms = platforms.linux;
  };
})
