{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "hp-wmi-fan-and-backlight-control";
  version = "0.0.2-unstable-2025-10-18";

  src = fetchFromGitHub {
    owner = "Vilez0";
    repo = "hp-wmi-fan-and-backlight-control";
    rev = "41f83a53235b2e2429fbb5ab887d3a915aabadfe";
    hash = "sha256-duhnkpBF1K233IU3HRCZMZhEanU+Ru5NlpkMQKCYMLs=";
  };

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
    homepage = "https://github.com/Vilez0/hp-wmi-fan-and-backlight-control";
    license = licenses.gpl2;
    maintainers = with maintainers; [ ern775 ];
    platforms = platforms.linux;
  };
})