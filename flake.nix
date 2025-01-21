{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      sbclPkgs = pkgs.sbcl.pkgs;
      inherit (pkgs) callPackage;
    in
    {
      packages.x86_64-linux = rec {
        default = neomacs-wrapper;
        named-closure = callPackage ./named-closure.nix { };
        lwcells = callPackage ./lwcells.nix { inherit named-closure; };
        _3bst = callPackage ./3bst.nix { };
        ceramic = sbclPkgs.ceramic.overrideAttrs (old: {
          src = pkgs.fetchFromGitHub {
            owner = "ceramic";
            repo = "ceramic";
            rev = "5d81e2bd954440a6adebde31fac9c730a698c74b";
            sha256 = "sha256-V6mgtIZDrZK7mgrtGIb90zx9/sWQu1tIpJUzIt8opUE=";
          };
        });
        neomacs = callPackage ./neomacs.nix { inherit lwcells _3bst ceramic; };
        neomacs-wrapper = callPackage ./neomacs-wrapper.nix { inherit lwcells _3bst ceramic neomacs; };
      };
    };
}
