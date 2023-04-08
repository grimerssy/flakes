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
      postgres = {
        path = ./postgres;
        description = "Postgresql flake template";
      };
    };
    defaultTemplate = self.templates.default;
  };
}
