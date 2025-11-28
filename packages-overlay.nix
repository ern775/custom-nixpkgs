{
  pkgs,
  inputs,
  ...
}:
{
  packages = {
    dopamine = pkgs.callPackage ./pkgs/dopamine/package.nix { };
    faugus-launcher = pkgs.callPackage ./pkgs/faugus-launcher/package.nix { };
    iloader = pkgs.callPackage ./pkgs/iloader/package.nix { };
    jdownloader2 = pkgs.callPackage ./pkgs/jdownloader2/package.nix { inherit inputs; };
    nero-umu = pkgs.callPackage ./pkgs/nero-umu/package.nix { };
    omenrgb = pkgs.callPackage ./pkgs/omenrgb/package.nix { };
    proton-ge-bin = pkgs.callPackage ./pkgs/proton-ge-bin/package.nix { };
    proton-spritz-bin = pkgs.callPackage ./pkgs/proton-spritz-bin/package.nix { };
    victus-control = pkgs.callPackage ./pkgs/victus-control/package.nix { };
  };
}
