{
  lib,
  buildGoModule,
  source,
}:

buildGoModule (finalAttrs: {
  inherit (source) pname version src;

  vendorHash = "sha256-XnBgNPPfDn5DCuN47gHw7ZssUon6pAxx2HARVF81W+s=";

  ldflags = [ "-s" ];

  meta = {
    description = "DPI bypass tool - eBPF on Linux, TUN on macOS/Windows";
    homepage = "https://github.com/boratanrikulu/gecit";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ern775 ];
    mainProgram = "gecit";
  };
})
