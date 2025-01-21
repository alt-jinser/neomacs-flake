{ lib
, fetchFromGitHub
, sbcl
  # ...
, lwcells
, _3bst
, ceramic
}:

sbcl.buildASDFSystem rec {
  pname = "neomacs";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "neomacs-project";
    repo = "neomacs";
    rev = version;
    hash = "sha256-b4QTmwW+byEqVMdyH3q45u0M92MgyBt15/qSaYcayjo=";
  };

  systems = [ "neomacs" "neomacs/term" ];

  lispLibs = with sbcl.pkgs; [
    deploy
    cffi-toolchain
    str
    parenscript
    lass
    spinneret
    metabang-bind
    cl-containers
    quri
    dexador
    trivial-types
    local-time
    dissect
    trivial-custom-debugger
    cl-tld
    osicat
    swank
    plump
    bknr_dot_datastore
    trivial-package-local-nicknames
    unix-opts
    bst
  ] ++ [
    lwcells
    _3bst
    ceramic
  ];

  meta = {
    description = "Structural Lisp IDE/browser/computing environment";
    homepage = "https://github.com/neomacs-project/neomacs";
    license = lib.licenses.gpl3Only;
    mainProgram = "neomacs";
    platforms = lib.platforms.all;
  };
}
