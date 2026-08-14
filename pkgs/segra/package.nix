{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDotnetModule,
  buildNpmPackage,
  dotnetCorePackages,
  makeWrapper,
  obs-studio,
  ffmpeg-full,
  webkitgtk_4_1,
  gtk3,
  glib,
  pipewire,
  wireplumber,
  xdg-desktop-portal,
  xdg-desktop-portal-gtk,
  zenity,
  libpulseaudio,
  pulseaudio,
  xrandr,
  xclip,
  gst_all_1,
  libnotify,
  gsettings-desktop-schemas,
  hicolor-icon-theme,
  dejavu_fonts,
  makeFontsConf,
  wrapGAppsHook3,
  pkg-config,
  callPackage,
}:

let
  # NOTE: v1.6.5 was Windows-only (single <TargetFramework>net10.0-windows...</TargetFramework>,
  # no Linux TFM at all -- that's why any csproj patching against it errors out with "no
  # <TargetFrameworks> element found"). Linux multi-targeting was added upstream in a later
  # release. v1.7.1 already ships a clean, separate `net10.0` TFM
  # (`<TargetFrameworks>net10.0-windows10.0.19041.0;net10.0</TargetFrameworks>`), so no csproj
  # patching is needed at all -- just restrict which TFM gets built via dotnetFlags.
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "Segergren";
    repo = "Segra";
    rev = "v${version}";
    hash = "sha256-YGSdykL1aEtghBPk22USWfDtUH7iaVRBmHtch7nbW8g=";
  };

  frontend = buildNpmPackage {
    pname = "segra-frontend";
    inherit version src;
    sourceRoot = "${src.name}/Frontend";
    npmDepsHash = "sha256-dvYTpIFVYyB4d1SgWgq8RfQZKciQisGCEiG8hQy6Tu0=";
    npmBuildScript = "build";
    env.SEGRA_VERSION = version;
    installPhase = ''
      mkdir -p $out
      cp -r dist/* $out/
    '';
  };

  # Extracted from OBS's official Ubuntu .deb -- see obs-helpers.nix.
  obsHelpers = callPackage ./obs-helpers.nix { };

  # obs-studio's own obs-plugins/ dir ships Qt/CEF/UI plugins (frontend-tools, obs-websocket,
  # obs-browser, decklink, *-ui) that assume a live QApplication + GUI event loop. Segra runs
  # OBS headless with no Qt app constructed, so loading one of these aborts the process
  # ("QWidget: Must construct a QApplication before a QWidget"). Obs/build-linux-bundle.sh and
  # publish/run.sh both curate the plugin set for exactly this reason on non-Nix builds; mirror
  # the same exclusion list here via a filtered symlink farm instead of pointing
  # SEGRA_OBS_MODULE_PATH straight at the uncurated system obs-studio plugin dir.
  obsPluginsCurated = stdenv.mkDerivation {
    pname = "segra-obs-plugins-curated";
    inherit version;
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      for so in ${obs-studio}/lib/obs-plugins/*.so; do
        b="$(basename "$so")"
        case "$b" in
          obs-browser.so|obs-websocket.so|frontend-tools.so|obs-vst.so|decklink*.so|*-ui.so) ;;
          *) ln -s "$so" "$out/$b" ;;
        esac
      done
      runHook postInstall
    '';
  };

  runtimeLibs = [
    webkitgtk_4_1
    gtk3
    glib
    libnotify
    pipewire
    wireplumber
    libpulseaudio
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-libav
  ];

  runtimeBins = [
    obs-studio
    ffmpeg-full
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    zenity
    pulseaudio
    xrandr
    xclip
  ];

  # WebKitGTK has no built-in fallback font -- with no FONTCONFIG_FILE pointing at real
  # scalable fonts, it renders everything with a tiny hardcoded bitmap font instead (the
  # "tiny and pixelated" UI). This is the standard nixpkgs pattern for giving a GTK/WebKit app
  # a font config: generate one with makeFontsConf and point FONTCONFIG_FILE at it below.
  fontsConf = makeFontsConf {
    fontDirectories = [ dejavu_fonts ];
  };

in
buildDotnetModule rec {
  pname = "segra";
  inherit version src;

  projectFile = "Segra.csproj";
  nugetDeps = ./deps.json;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  selfContainedBuild = true;
  useAppHost = true;
  runtimeId = "linux-x64";

  postPatch = ''
    rm -rf Frontend/dist Resources/wwwroot
    mkdir -p Frontend/dist Resources/wwwroot
    cp -r ${frontend}/. Frontend/dist/
    cp -r ${frontend}/. Resources/wwwroot/

    # NuGet's Restore target evaluates the FULL <TargetFrameworks> list from the csproj no
    # matter what -p:TargetFramework(s) is passed on the command line (that override only
    # affects Build/Publish, never Restore) -- so it always tries to restore the Windows-only
    # TFM's packages too (NAudio, System.Management, Vortice.DirectX), which are deliberately
    # not in deps.json. Collapse to the single net10.0 TFM directly in the csproj so restore
    # never sees the Windows target at all. Verified byte-identical against the real v${version}
    # tag (raw.githubusercontent.com) -- --replace-fail aborts loudly instead of silently
    # no-op'ing if that ever drifts on a future version bump.
    substituteInPlace Segra.csproj \
      --replace-fail \
        '<TargetFrameworks>net10.0-windows10.0.19041.0;net10.0</TargetFrameworks>' \
        '<TargetFramework>net10.0</TargetFramework>'
  '';

  executables = [ "Segra" ];

  nativeBuildInputs = [
    makeWrapper
    wrapGAppsHook3
    pkg-config
  ];
  buildInputs = runtimeLibs ++ [
    gsettings-desktop-schemas
    hicolor-icon-theme
  ];

  postInstall = ''
    mkdir -p $out/lib/${pname}/wwwroot
    cp -r ${frontend}/. $out/lib/${pname}/wwwroot/

    # Beside the real Segra binary, not the bin/ wrapper: libobs resolves
    # these via readlink(/proc/self/exe), which for a wrapped app is the
    # actual executable in lib/${pname}/, not the bin/ shell shim.
    install -m755 ${obsHelpers}/obs-nvenc-test  $out/lib/${pname}/obs-nvenc-test
    install -m755 ${obsHelpers}/obs-ffmpeg-mux  $out/lib/${pname}/obs-ffmpeg-mux
  '';

  postFixup = ''
    wrapProgram $out/bin/Segra \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath (runtimeLibs ++ [ obs-studio ])} \
      --prefix PATH : ${lib.makeBinPath runtimeBins} \
      --set SEGRA_OBS_MODULE_PATH "${obsPluginsCurated}" \
      --set SEGRA_OBS_MODULE_DATA_PATH "${obs-studio}/share/obs/obs-plugins/%module%" \
      --set SEGRA_OBS_DATA_PATH "${obs-studio}/share/obs/libobs" \
      --set FONTCONFIG_FILE "${fontsConf}" \
      --set GST_PLUGIN_SYSTEM_PATH_1_0 "${
        lib.makeSearchPath "lib/gstreamer-1.0" [
          gst_all_1.gstreamer
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
          gst_all_1.gst-plugins-bad
          gst_all_1.gst-libav
        ]
      }" \
      --chdir "$out/lib/${pname}"
  '';

  meta = with lib; {
    description = "Open-source game recorder built on OBS";
    homepage = "https://github.com/Segergren/Segra";
    license = licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "Segra";
    maintainers = [ ];
  };
}
