{ lib
, fetchFromGitHub
, sbcl
}:

sbcl.buildASDFSystem {
  pname = "3bst";
  version = "unstable-2024-11-23";

  src = fetchFromGitHub {
    owner = "neomacs-project";
    repo = "3bst";
    rev = "c593889daf77abe7781e83cfd1c1831b29d802c9";
    hash = "sha256-FiTjUpkxUikRqCtvBSiEaJ2VOjKhHXDi/e8c2opFrHs=";
  };

  lispLibs = with sbcl.pkgs; [
    alexandria
    split-sequence
  ];

  meta = {
    description = "CL port of the terminal emulation part of st (http://st.suckless.org)";
    homepage = "https://github.com/neomacs-project/3bst";
    platforms = lib.platforms.all;
  };
}
