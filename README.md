# Nur-packages

![Build Status](https://github.com/ern775/custom-nixpkgs/workflows/build%20and%20upload%20to%20cachix/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-ern775-blue.svg)](https://ern775-nixpkgs.cachix.org)

My personal [NUR](https://github.com/nix-community/NUR) repository.

It also provides a pre-compiled binary cache for NixOS unstable.

To use it add the following to your NixOS configuration.nix:
```nix
  nix = {
    settings = {
      substituters = [
        "https://ern775-nixpkgs.cachix.org"
      ];
      trusted-public-keys = [
        "ern775-nixpkgs.cachix.org-1:TurFfb4SY0Reec+lLRhtafxyCLS/p9mfvoDMwtAKXrw="
      ];
    };
  };
```
or simply add it to your nix.conf:
```
substituters = https://ern775-nixpkgs.cachix.org
trusted-public-keys = ern775-nixpkgs.cachix.org-1:TurFfb4SY0Reec+lLRhtafxyCLS/p9mfvoDMwtAKXrw=
```