{ writeShellApplication
, runCommand
, callPackage
, sbcl
, electron
  # ...
, lwcells
, _3bst
, ceramic
, neomacs
}:

let
  sbcl' = sbcl.withOverrides (self: super: { inherit neomacs; });
  sbclWithNeomacs = sbcl'.withPackages (ps: [ ps.neomacs ]);
  env.nativeBuildInputs = [ sbclWithNeomacs ];
  ceramic-directory = runCommand "ceramic-directory" env ''
    set -euo pipefail

    mkdir -p "$out"
    cp -r ${electron}/* "$out"
    chmod -R u+w "$out"

    sbcl \
      --eval '(load (sb-ext:posix-getenv "ASDF"))' \
      --eval "(asdf:load-system 'ceramic)" \
      --eval "(setq ceramic.file::*ceramic-directory* \"$out/libexec/\")" \
      --eval "(ceramic:setup)" \
      --quit
  '';

  patchedCeramic = ceramic.overrideAttrs (final: prev: {
    patchPhase = ''
      sed -i 's|(trivial-exe:executable-pathname)|#p"${ceramic-directory}"|' src/runtime.lisp
    '';
  });
  patchedNeomacs = callPackage ./neomacs.nix { inherit lwcells _3bst; ceramic = patchedCeramic; };
  # patchedNeomacs = neomacs.overrideAttrs (final: prev: {
  #   lispLibs = (builtins.filter (n: n.pname != "sbcl-ceramic") prev.lispLibs) ++ [ patchedCeramic ];
  #   propagatedBuildInputs = final.lispLibs;
  # });

  sbcl'' = sbcl.withOverrides (self: super: { neomacs = patchedNeomacs; });
  sbclWithNeomacs' = sbcl''.withPackages (ps: [ ps.neomacs ]);
in
writeShellApplication {
  name = "neomacs";
  runtimeInputs = [ sbclWithNeomacs' ];
  text = ''
    sbcl \
      --eval '(load (sb-ext:posix-getenv "ASDF"))' \
      --eval "(asdf:load-system 'ceramic)" \
      --eval "(asdf:load-system 'neomacs)" \
      --eval '(setq ceramic.runtime:*releasep* t)'
      # --eval '(neomacs:start nil)' \
      # --quit
  '';
}
