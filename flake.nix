{
  description = "A collection of flake templates";

  outputs = { self }: {
    templates = {
      default = {
        path = ./default;
        description = "Default flake template";
      };
      rust = {
        path = ./rust;
        description = "Rust flake template";
      };
    };
    defaultTemplate = self.templates.default;
  };
}
