{
  outputs = { self }:
    let
      files = builtins.readDir ./.;
      isDotfile = file: builtins.length (builtins.split "^\\." file) != 1;
      isCollection = file: files.${file} == "directory" && !isDotfile file;
      collections = builtins.filter isCollection (builtins.attrNames files);
      mkTemplates = collection:
        let
          collectionPath = ./. + "/${collection}";
          templateNames = builtins.attrNames (builtins.readDir collectionPath);
          mkTemplate = name: {
            inherit name;
            value.path = collectionPath + "/${name}";
          };
        in
        builtins.listToAttrs (map mkTemplate templateNames);
      mkCollection = name: {
        inherit name;
        value = mkTemplates name;
      };
    in
    {
      templates = builtins.listToAttrs (map mkCollection collections);
    };
}
