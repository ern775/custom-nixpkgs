{
  lib,
  buildGoModule,
  source,
  vendorHash,
}:
buildGoModule {
  inherit (source) pname version src;

  inherit vendorHash;

  subPackages = [ "cmd/gobee" ];

  meta = {
    description = "";
    homepage = "https://github.com/boratanrikulu/gobee";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ern775 ];
    mainProgram = "gobee";
  };
}
