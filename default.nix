# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
  lib,
  ...
}:
let
  nvSources = pkgs.callPackage ./_sources/generated.nix { };
  vendorHashes = lib.importJSON ./pkgs/vendorHashes.json;
  mkCachyProton =
    sourceKey: variantName:
    pkgs.callPackage ./pkgs/proton-cachyos/package.nix {
      source = nvSources.${sourceKey};
      variant = variantName;
    };
in
rec {
  bevy-gamestation = pkgs.callPackage ./pkgs/bevy-gamestation/package.nix { };
  dopamine = pkgs.callPackage ./pkgs/dopamine/package.nix { source = nvSources.dopamine; };
  dw-proton = pkgs.callPackage ./pkgs/dw-proton/package.nix { source = nvSources.dw-proton; };
  gecit = pkgs.callPackage ./pkgs/gecit/package.nix {
    source = nvSources.gecit;
    vendorHash = vendorHashes.gecit;
    gobee = gobee;
  };
  gobee = pkgs.callPackage ./pkgs/gobee/package.nix {
    source = nvSources.gobee;
    vendorHash = vendorHashes.gobee;
  };
  handbrake = pkgs.callPackage ./pkgs/handbrake/package.nix {
    source = nvSources.handbrake;
    rev = nvSources.handbrake-rev.version;
  };
  iloader = pkgs.callPackage ./pkgs/iloader/package.nix {
    source = nvSources.iloader;
    bunOutputHash = vendorHashes.iloader;
  };
  jdownloader2 = pkgs.callPackage ./pkgs/jdownloader2/package.nix {
    source = nvSources.jdownloader2;
  };
  jellyfin-desktop = pkgs.callPackage ./pkgs/jellyfin-desktop/package.nix { };
  mpv-prism-native = pkgs.callPackage ./pkgs/seanime/mpv-prism.nix {
    mpv-prism-native-sources = {
      x86_64-linux = nvSources.mpv-prism-linux-x64;
      aarch64-darwin = nvSources.mpv-prism-darwin-arm64;
    };
  };
  nero-umu = pkgs.callPackage ./pkgs/nero-umu/package.nix { source = nvSources.nero-umu; };
  # omenrgb = pkgs.callPackage ./pkgs/omenrgb/package.nix { source = nvSources.omenrgb; };
  prismlauncher = pkgs.callPackage ./pkgs/prismlauncher/package.nix {
    prismlauncher-unwrapped = prismlauncher-unwrapped;
  };
  prismlauncher-unwrapped = pkgs.callPackage ./pkgs/prismlauncher/unwrapped.nix {
    source = nvSources.prismlauncher;
  };
  proton-cachyos = mkCachyProton "proton-cachyos-x86_64-v3" "x86_64-v3";
  # proton-ge-bin = pkgs.callPackage ./pkgs/proton-ge-bin/package.nix {
  #   source = nvSources.proton-ge-bin;
  # };
  seanime = pkgs.callPackage ./pkgs/seanime/package.nix {
    source = nvSources.seanime;
    vendorHash = vendorHashes.seanime;
    mpv-prism = mpv-prism-native;
  };
  seanime-bin-canary = pkgs.callPackage ./pkgs/seanime-bin-canary/package.nix {
    source = nvSources.seanime-bin-canary;
  };
  # seanime-canary = pkgs.callPackage ./pkgs/seanime-canary/package.nix {
  #   source = nvSources.seanime-canary;
  #   vendorHash = vendorHashes.seanime-canary;
  # };
  solidtime-desktop = pkgs.callPackage ./pkgs/solidtime-desktop/package.nix { };
  victus-control = pkgs.callPackage ./pkgs/victus-control/package.nix {
    source = nvSources.victus-control;
  };
  visual-paradigm-ce = pkgs.callPackage ./pkgs/visual-paradigm-ce/package.nix { };
  wire-desktop = pkgs.callPackage ./pkgs/wire-desktop/package.nix { };
}
