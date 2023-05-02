{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        packages = with pkgs; [ postgresql ];
        envVarDefaults = {
          DEVSHELL_DIR = "$PWD/.devshell";
          PGDATA = "$DEVSHELL_DIR/postgresql";
          PGLOG = "$PGDATA/logfile";
          PGPORT = "5432";
          PGUSER = "postgres";
        };
        scripts = {
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
        overlays = [ ];
        toBinScripts = scripts:
          builtins.attrValues
          (builtins.mapAttrs (name: text: (pkgs.writeShellScriptBin name text))
            scripts);
        setEnvVarsIfUnset = set:
          builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs
            (name: value: ''export ${name}=''${${name}:="${value}"}'') set));
      in {
        devShells.default = pkgs.mkShellNoCC {
          buildInputs = packages ++ (toBinScripts scripts);
          shellHook = ''
            ${setEnvVarsIfUnset envVarDefaults}
          '';
        };
      });
}
