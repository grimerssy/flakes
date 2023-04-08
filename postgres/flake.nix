{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        postgres = {
          version = "15.0";
          port = 5432;
          user = "postgres";
        };

        packages = with pkgs; [ postgresql ];
        shellHook = ''
          local state_dir="$PWD/.devshell"
          export PGDATA="$state_dir/postgresql"
          export PGLOG="$PGDATA/logfile"
          export PGPORT=${toString postgres.port}
          export PGUSER="${postgres.user}"
        '';

        scripts = toBinScripts {
          setup = ''
            pg_ctl init -o "-U $PGUSER" -o '--auth=trust'
            echo "port = $PGPORT" >> "$PGDATA/postgresql.conf"
          '';
          up = ''
            pg_ctl start -l "$PGLOG"
          '';
          down = ''
            pg_ctl stop 
          '';
        };

        pkgs = import nixpkgs { inherit system overlays; };
        overlays = [
          (self: super: {
            postgresql = super.postgresql.overrideAttrs (prev: {
              src = fetchTarball {
                url = "https://ftp.postgresql.org/pub/source"
                  + "/v${postgres.version}/postgresql-${postgres.version}.tar.gz";
                sha256 = pkgs.lib.fakeSha256;
              };
            });
          })
        ];
        toBinScripts = scripts:
          builtins.attrValues
          (builtins.mapAttrs (name: text: (pkgs.writeShellScriptBin name text))
            scripts);
      in {
        devShells.default = pkgs.mkShellNoCC {
          inherit shellHook;
          buildInputs = packages ++ scripts;
        };
      });
}
