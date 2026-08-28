{
  lib,
  buildGoModule,
  source,
  vendorHash,
  clang,
  libbpf,
  libllvm,
  gobee,
}:
buildGoModule (finalAttrs: {
  inherit (source) pname date src;
  version = "0.1.4-unstable-${finalAttrs.date}";

  inherit vendorHash;

  proxyVendor = true;

  nativeBuildInputs = [
    clang
    gobee
    libllvm
  ];

  buildInputs = [
    libbpf
  ];

  hardeningDisable = [
    "zerocallusedregs"
    "stackprotector"
    "stackclashprotection"
  ];

  preBuild = ''
    export GOROOT="$(go env GOROOT)"
    make bpf-translate
  '';

  meta = {
    description = "DPI bypass tool - eBPF on Linux, TUN on macOS/Windows";
    homepage = "https://github.com/boratanrikulu/gecit";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ern775 ];
    mainProgram = "gecit";
  };
})
