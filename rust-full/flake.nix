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
        devPackages = with pkgs; [
          rust-toolchain
          cargo-edit
          cargo-nextest
          postgresql
          redis
        ];
        scripts = {
          setup = ''
            pg_ctl init -o "-U $PGUSER" -o '--auth=trust'
            echo "port = $PGPORT" >> "$PGDATA/postgresql.conf"
            mkdir -p "$REDIS_DATA"
          '';
          up = ''
            pg_ctl start -l "$PGLOG"
            redis-server --daemonize yes --dir "$REDIS_DATA" --port "$REDIS_PORT"
          '';
          down = ''
            pg_ctl stop 
            redis-cli -p "$REDIS_PORT" shutdown
          '';
          redis = ''
            redis-cli -p "$REDIS_PORT"
          '';
        };

        buildInputs = with pkgs; [ openssl ];
        nativeBuildInputs = with pkgs;
          [ pkg-config ] ++ lib.optionals stdenv.isDarwin
          (with darwin.apple_sdk.frameworks; [
            CoreServices
            Security
            SystemConfiguration
          ]);
        envVarDefaults = {
          DEVSHELL_DIR = "$PWD/.devshell";
          PGDATA = "$DEVSHELL_DIR/postgresql";
          PGLOG = "$PGDATA/logfile";
          PGPORT = "5432";
          PGUSER = "postgres";
          REDIS_DATA = "$DEVSHELL_DIR/redis";
          REDIS_PORT = "6379";
        };

        pkgs = import nixpkgs { inherit system overlays; };
        overlays = [
          (import rust-overlay)
          (self: super: {
            rust-toolchain = super.rust-bin.stable.latest.default;
          })
        ];
        devShells.default = pkgs.mkShellNoCC {
          inherit buildInputs nativeBuildInputs;
          packages = devPackages ++ (toBinScripts scripts);
          shellHook = ''
            ${setEnvVarsIfUnset envVarDefaults}
          '';
        };
        naersk' = pkgs.callPackage naersk rec {
          cargo = rustc;
          rustc = pkgs.rust-toolchain;
        };
        toBinScripts = scripts:
          builtins.attrValues
          (builtins.mapAttrs (name: text: (pkgs.writeShellScriptBin name text))
            scripts);
        setEnvVarsIfUnset = set:
          builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs
            (name: value: ''export ${name}=''${${name}:="${value}"}'') set));
      };
    in flake-utils.lib.eachDefaultSystem forEachSystem;
}
