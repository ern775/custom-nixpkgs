{
  lib,
  stdenv,
  autoPatchelfHook,
  glib,
  libGL,
  libgbm,
  libva,
  mpv-prism-native-sources,
}:

let
  version = (lib.head (lib.attrValues mpv-prism-native-sources)).version;
  sources = lib.mapAttrs (_: v: v.src) mpv-prism-native-sources;
in
stdenv.mkDerivation {
  pname = "mpv-prism-electron-native";
  inherit version;

  src =
    sources.${stdenv.hostPlatform.system}
      or (throw "mpv-prism: unsupported system ${stdenv.hostPlatform.system}");

  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    stdenv.cc.cc.lib
    glib
    libGL
    libgbm
    libva
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . "$out/"
    runHook postInstall
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    rm -f "$out"/{libglib-2.0.so.0}
  '';

  meta = {
    description = "Prebuilt libmpv native module for Seanime's mpv-prism player";
    homepage = "https://seanime.app";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
}
