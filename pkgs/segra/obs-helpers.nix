{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
}:

let
  # Match Obs/build-linux-bundle.sh's defaults: oldest supported Ubuntu base
  # keeps the glibc/FFmpeg floor low. Bump alongside OBS_VERSION in
  # build-flatpak.sh when the project moves to a newer OBS release.
  version = "32.2.0";
  ubuntuBase = "24.04";

  deb = fetchurl {
    url = "https://github.com/obsproject/obs-studio/releases/download/${version}/OBS-Studio-${version}-Ubuntu-${ubuntuBase}-x86_64.deb";
    # nix-prefetch-url <url>
    hash = "sha256-S2kb7x6rulAubXWS+H0JBJr1bQDYPwYIentEfMfBnZg=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "segra-obs-helpers";
  inherit version;

  src = deb;
  dontUnpack = true;
  nativeBuildInputs = [ dpkg ];

  # obs-nvenc-test (NVENC capability probing) and obs-ffmpeg-mux (recording/
  # replay-buffer muxing) are subprocess helpers libobs launches by resolving
  # its own executable's path (readlink /proc/self/exe) and looking beside
  # it -- NOT via $PATH and not shipped as a normal obs-plugins/*.so. They
  # only exist prebuilt inside OBS's own package, same source
  # Obs/build-linux-bundle.sh extracts them from for the non-Nix builds.
  installPhase = ''
    runHook preInstall
    dpkg-deb -x "$src" root
    mkdir -p $out
    for h in obs-nvenc-test obs-ffmpeg-mux; do
      f="$(find root -type f -name "$h" | head -1)"
      [ -n "$f" ] || { echo "error: $h not found in OBS ${version} deb"; exit 1; }
      install -m755 "$f" "$out/$h"
    done
    runHook postInstall
  '';

  meta = with lib; {
    description = "obs-nvenc-test / obs-ffmpeg-mux subprocess helpers extracted from OBS Studio's official Ubuntu .deb";
    homepage = "https://github.com/obsproject/obs-studio";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
  };
}