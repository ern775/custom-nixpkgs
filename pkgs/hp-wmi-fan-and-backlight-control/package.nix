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

  preConfigure = ''
    sed -i -e '/depmod/d' ./Makefile
  '';

  enableParallelBuilding = true;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=${placeholder "out"}"
    "INSTALL_MOD_DIR=extra"
    "DEPMOD=true"
  ];

  installTargets = [ "modules_install" ];
  installFlags = [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)"
  ];

  meta = with lib; {
    description = "Linux kernel module for HP Laptops";
    homepage = "https://github.com/TUXOV/hp-wmi-fan-and-backlight-control";
    license = licenses.gpl2;
    maintainers = with maintainers; [ ern775 ];
    platforms = platforms.linux;
  };
})
