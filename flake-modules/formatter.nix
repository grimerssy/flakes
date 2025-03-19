{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];
  perSystem.treefmt = {
    projectRootFile = "flake.nix";
    programs.nixfmt.enable = true;
    programs.prettier.enable = true;
    settings.global.excludes = [
      "LICENSE"
      ".editorconfig"
      "*/.envrc"
      "*/.editorconfig"
      "*/.gitignore"
    ];
  };
}
