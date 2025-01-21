{ lib
, fetchFromGitHub
, sbcl
, named-closure
}:

sbcl.buildASDFSystem {
  pname = "lwcells";
  version = "unstable-2024-10-06";

  src = fetchFromGitHub {
    owner = "kchanqvq";
    repo = "lwcells";
    rev = "e7446ac146a31b630e74c9bce7dab34b50cc333d";
    hash = "sha256-zI67bTVQ6gP7Qm17k9PydnOetTPM+H4NJ+HqKIosCt0=";
  };

  lispLibs = with sbcl.pkgs; [
    alexandria
    damn-fast-stable-priority-queue
  ] ++ [
    named-closure
  ];

  meta = {
    description = "Light Weight Cells";
    homepage = "https://github.com/kchanqvq/lwcells";
    mainProgram = "lwcells";
    platforms = lib.platforms.all;
  };
}
