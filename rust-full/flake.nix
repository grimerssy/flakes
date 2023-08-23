{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    let
      mkDevShell = pkgs: {
        packages = with pkgs; [
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
        envVarDefaults = {
          DEVSHELL_DIR = "$PWD/.devshell";
          PGDATA = "$DEVSHELL_DIR/postgresql";
          PGLOG = "$PGDATA/logfile";
          PGPORT = "5432";
          PGUSER = "postgres";
          REDIS_DATA = "$DEVSHELL_DIR/redis";
          REDIS_PORT = "6379";
        };
        buildInputs = with pkgs; [ openssl ];
        nativeBuildInputs = with pkgs;
          [ pkg-config ] ++ lib.optionals stdenv.isDarwin
          (with darwin.apple_sdk.frameworks; [
            CoreServices
            Security
            SystemConfiguration
          ]);
      };
    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system overlays; };
        overlays = [
          (import rust-overlay)
          (self: super: {
            rust-toolchain = super.rust-bin.stable.latest.default;
          })
        ];
        devShell = mkDevShell pkgs;
        toBinScripts = scripts:
          builtins.attrValues
          (builtins.mapAttrs (name: text: (pkgs.writeShellScriptBin name text))
            scripts);
        setEnvVarsIfUnset = set:
          builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs
            (name: value: ''export ${name}=''${${name}:="${value}"}'') set));
      in {
        devShells.default = pkgs.mkShellNoCC {
          packages = devShell.packages ++ (toBinScripts devShell.scripts);
          buildInputs = devShell.buildInputs;
          nativeBuildInputs = devShell.nativeBuildInputs;
          shellHook = ''
            ${setEnvVarsIfUnset devShell.envVarDefaults}
          '';
        };
      });
}
