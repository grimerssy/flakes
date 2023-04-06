{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        buildInputs = with pkgs; [ hello ];
        pkgs = import nixpkgs { inherit system overlays; };
        overlays = [ (self: super: { }) ];
      in { devShells.default = pkgs.mkShellNoCC { inherit buildInputs; }; });
}
