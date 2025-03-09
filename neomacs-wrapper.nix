{
  writeShellApplication,
  runCommand,
  callPackage,
  sbcl,
  electron,
  # ...
  lwcells,
  _3bst,
  ceramic,
  neomacs,
}:

let
  sbcl' = sbcl.withOverrides (self: super: { inherit neomacs; });
  sbclWithNeomacs = sbcl'.withPackages (ps: [ ps.neomacs ]);
  env.nativeBuildInputs = [ sbclWithNeomacs ];
  ceramic-directory = runCommand "ceramic-directory" env ''
    set -euo pipefail

    mkdir "$out"
    cp -r ${electron.dist} "$out/electron"
    cp -r ${electron}/bin "$out/bin"

    # sbcl \
    #   --no-sysinit --no-userinit --non-interactive \
    #   --eval '(load (sb-ext:posix-getenv "ASDF"))' \
    #   --eval "(asdf:load-system 'ceramic)" \
    #   --eval "(setq ceramic.file::*ceramic-directory* \"$out/\")" \
    #   --eval "(ceramic:setup)"
  '';

  patchedCeramic = ceramic.overrideLispAttrs (old: {
    buildPhase = ''
      runHook preBuild

      export CL_SOURCE_REGISTRY=$CL_SOURCE_REGISTRY:$(pwd)//
      export ASDF_OUTPUT_TRANSLATIONS="$src:$(pwd):/nix/store:/nix/store"
      ${old.pkg}/bin/sbcl --dynamic-space-size 3000 < $buildScript

      runHook postBuild
    '';
    patchPhase = ''
      runHook prePatch

      substituteInPlace src/runtime.lisp \
        --replace-fail '(trivial-exe:executable-pathname)' '#p"${ceramic-directory}/"'

      runHook postPatch
    '';
  });
  patchedNeomacs = callPackage ./neomacs.nix {
    inherit lwcells _3bst;
    ceramic = patchedCeramic;
  };

  sbcl'' = sbcl.withOverrides (self: super: { neomacs = patchedNeomacs; });
  sbclWithNeomacs' = sbcl''.withPackages (ps: [ ps.neomacs ]);
in
writeShellApplication {
  name = "neomacs";
  runtimeInputs = [ sbclWithNeomacs' ];
  text = ''
    sbcl \
      --no-sysinit --no-userinit \
      --eval '(load (sb-ext:posix-getenv "ASDF"))' \
      --eval "(asdf:load-system 'ceramic)" \
      --eval "(asdf:load-system 'neomacs)" \
      --eval '(setq ceramic.runtime:*releasep* t)' \
      --eval '(neomacs:start nil)'
  '';
}
