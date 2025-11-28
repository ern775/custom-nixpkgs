{
  pkgs,
  inputs,
  ...
}:
{
  packages = {
    iloader = pkgs.callPackage ./pkgs/iloader/package.nix { };
    # nero-umu = pkgs.callPackage ./pkgs/nero-umu/package.nix { inherit inputs; };
    faugus-launcher = pkgs.callPackage ./pkgs/faugus-launcher/package.nix { };
    hayase = pkgs.callPackage ./pkgs/hayase/package.nix { };
    mindustry-beta = pkgs.callPackage ./pkgs/mindustry/package.nix { };
    vlc-3-0-20 = pkgs.callPackage ./pkgs/vlc/package.nix { };
    dopamine = pkgs.callPackage ./pkgs/dopamine/package.nix { inherit inputs; };
    victus-control = pkgs.callPackage ./pkgs/victus-control/package.nix { };
  };
}
