{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    literalExpression
    ;
  cfg = config.hardware.hp-wmi-control;
  nvSources = pkgs.callPackage ../../_sources/generated.nix { };
in
{
  imports = [
    (lib.mkRemovedOptionModule [
      "hardware"
      "hp-wmi-control"
      "victus-15-support"
      "enable"
    ] "The driver now detects boards by DMI name; this option is no longer needed.")
  ];

  options.hardware.hp-wmi-control = {
    enable = mkEnableOption "the hp-wmi-fan-and-backlight-control kernel module";

    package = mkOption {
      type = types.package;
      default =
        config.boot.kernelPackages.callPackage ../../pkgs/hp-wmi-fan-and-backlight-control/package.nix
          { source = nvSources.hp-wmi-fan-and-backlight-control; };
      defaultText = literalExpression "config.boot.kernelPackages.callPackage ../../pkgs/hp-wmi-fan-and-backlight-control/package.nix { ... }";
      description = "The kernel module package, built against the configured kernel.";
    };
  };

  config = mkIf cfg.enable {
    boot.extraModulePackages = [ cfg.package ];
  };
}
