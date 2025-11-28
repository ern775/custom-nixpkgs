{
  stdenv,
  lib,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation {
  pname = "acer-predator-turbo-rgb";
  version = "main";

  src = fetchFromGitHub {
    owner = "JafarAkhondali";
    repo = "acer-predator-turbo-and-rgb-keyboard-linux-module";
    rev = "343c715669ef52ccecdb65473e7318f612b6b6c2";
    hash = "sha256-RKqe3kHZ32Pv+6skP4x+sB+c4dlyES0Bu2C73LvkgqQ=";
  };

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
}
