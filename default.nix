# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  nvSources = pkgs.callPackage ./_sources/generated.nix { };
  mkCachyProton =
    sourceKey: variantName:
    pkgs.callPackage ./pkgs/proton-cachyos/package.nix {
      source = nvSources.${sourceKey};
      variant = variantName;
    };
in
{
  # The `lib`, `modules`, and `overlays` names are special
  # lib = import ./lib { inherit pkgs; }; # functions
  # modules = import ./modules; # NixOS modules
  # overlays = import ./overlays; # nixpkgs overlays

  dopamine = pkgs.callPackage ./pkgs/dopamine/package.nix { source = nvSources.dopamine; };
  iloader = pkgs.callPackage ./pkgs/iloader/package.nix { source = nvSources.iloader; };
  jdownloader2 = pkgs.callPackage ./pkgs/jdownloader2/package.nix {
    source = nvSources.jdownloader2;
  };
  nero-umu = pkgs.callPackage ./pkgs/nero-umu/package.nix { source = nvSources.nero-umu; };
  omenrgb = pkgs.callPackage ./pkgs/omenrgb/package.nix { source = nvSources.omenrgb; };
  proton-cachyos = mkCachyProton "proton-cachyos-x86_64-v3" "x86_64-v3";
  proton-ge-bin = pkgs.callPackage ./pkgs/proton-ge-bin/package.nix {
    source = nvSources.proton-ge-bin;
  };
  victus-control = pkgs.callPackage ./pkgs/victus-control/package.nix {
    source = nvSources.victus-control;
  };
  seanime = pkgs.callPackage ./pkgs/seanime/package.nix { source = nvSources.seanime; };
  seanime-denshi = pkgs.callPackage ./pkgs/seanime-denshi/package.nix {
    source = nvSources.seanime-denshi;
  };
  seanime-denshi-for-nixpkgs = pkgs.callPackage ./pkgs/seanime-denshi/package-for-nixpkgs.nix { };
}
