{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        buildInputs = with pkgs; [ rust ];

        pkgs = import nixpkgs { inherit system overlays; };
        overlays = [
          (self: super: {
            rust = (import nixpkgs {
              inherit system;
              overlays = [ (import rust-overlay) ];
            }).rust-bin.stable.latest.default.override {
              extensions = [ "rust-src" ];
            };
          })
        ];
      in {
        devShells.default = pkgs.mkShellNoCC {
          buildInputs = buildInputs ++ (with pkgs;
            lib.optionals stdenv.isDarwin
            (with darwin.apple_sdk.frameworks; [ ]));
        };
      });
}
