{
  source,
  stdenv,
  lib,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hp-wmi-fan-and-backlight-control";

  inherit (source) date src;
  version = "0-unstable-${finalAttrs.date}";

  setSourceRoot = ''
    export sourceRoot=$(pwd)/source
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(sourceRoot)"
  ];

  enableParallelBuilding = true;

  buildFlags = [ "modules" ];

  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];

  installTargets = [ "modules_install" ];

  meta = with lib; {
    description = "Linux kernel module for HP Laptops";
    homepage = "https://github.com/TUXOV/hp-wmi-fan-and-backlight-control";
    license = licenses.gpl2;
    maintainers = with maintainers; [ ern775 ];
    platforms = platforms.linux;
  };
})