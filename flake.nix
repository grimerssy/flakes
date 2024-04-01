{
  outputs = { self }:
    let
      files = builtins.readDir ./.;
      directories = builtins.filter (file: files.${file} == "directory")
        (builtins.attrNames files);
    in
    {
      templates = builtins.listToAttrs (builtins.map
        (dir: { name = dir; value.path = ./${dir}; })
        directories
      );
    };
}
