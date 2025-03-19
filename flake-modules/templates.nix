{ self, ... }:
{
  flake = {
    defaultTemplate = self.templates.basic;
    templates = {
      basic = {
        path = ../basic;
        description = "A basic flake to build upon";
      };
      rust = {
        path = ../rust;
        description = "A development shell for Rust";
      };
    };
  };
}
