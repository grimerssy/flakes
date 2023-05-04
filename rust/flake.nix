{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    naersk.url = "github:nix-community/naersk";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, naersk, rust-overlay, flake-utils }:
    let
      forEachSystem = system: rec {
        packages = {
          default = naersk'.buildPackage {
            inherit buildInputs nativeBuildInputs;
            src = ./.;
          };
        };
        devShells.default = pkgs.mkShellNoCC {
          inherit buildInputs nativeBuildInputs;
          packages = with pkgs; [ rust-toolchain ];
        };
        buildInputs = with pkgs; [ openssl ];
        nativeBuildInputs = with pkgs;
          [ pkg-config ] ++ lib.optionals stdenv.isDarwin
          (with darwin.apple_sdk.frameworks; [
            CoreServices
            Security
            SystemConfiguration
          ]);

        pkgs = import nixpkgs { inherit system overlays; };
        overlays = [
          (import rust-overlay)
          (self: super: {
            rust-toolchain = super.rust-bin.stable.latest.default;
          })
        ];
        naersk' = pkgs.callPackage naersk rec {
          cargo = rustc;
          rustc = pkgs.rust-toolchain;
        };
      };
    in flake-utils.lib.eachDefaultSystem forEachSystem;
}
