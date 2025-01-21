{ lib
, fetchFromGitHub
, sbcl
}:

sbcl.buildASDFSystem {
  pname = "named-closure";
  version = "d57305";

  src = fetchFromGitHub {
    owner = "kchanqvq";
    repo = "named-closure";
    rev = "d57305582137a24d6c8f8375fba496c653bb5699";
    sha256 = "sha256-xfXyblX8aNUFFFH5SFibIYMiVWi2ySvhuwlWdSbVl54=";
  };

  lispLibs = with sbcl.pkgs; [
    alexandria
    closer-mop
    serapeum
  ];

  meta = {
    description = "Introspectable, readably-printable and redefinable closures";
    homepage = "https://github.com/kchanqvq/named-closure";
    platforms = lib.platforms.all;
  };
}
