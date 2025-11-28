{
  description = "nixon pkgs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    jdownloader = {
      url = "https://installer.jdownloader.org/JDownloader.jar";
      flake = false;
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        ((import ./packages-overlay.nix { inherit inputs pkgs; }).packages)
      );
    };
}
