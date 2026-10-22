{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf mkOption types literalExpression;
  cfg = config.hardware.hp-wmi-control;
  nvSources = pkgs.callPackage ../../_sources/generated.nix { };
in
{
  options.hardware.hp-wmi-control = {
    enable = mkEnableOption "the hp-wmi-fan-and-backlight-control kernel module";

    package = mkOption {
      type = types.package;
      default = config.boot.kernelPackages.callPackage
        ../../pkgs/hp-wmi-fan-and-backlight-control/package.nix
        { source = nvSources.hp-wmi-fan-and-backlight-control; };
      defaultText = literalExpression "config.boot.kernelPackages.callPackage ../../pkgs/hp-wmi-fan-and-backlight-control/package.nix { ... }";
      description = "The kernel module package, built against the configured kernel.";
    };

    victus-15-support.enable = mkEnableOption "forced manual fan control support for Victus 15 laptops";
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ cfg.package ];

    boot.extraModprobeConfig = mkIf cfg.victus-15-support.enable ''
      options hp-wmi force_fan_control_support=true
    '';
  };
}
