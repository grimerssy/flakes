{
  description = "A collection of flake templates";

  outputs = { self }: {
    templates = {
      simple = {
        path = ./simple;
        description = "Hello world of flakes";
      };
      rust = {
        path = ./rust;
        description = "A rust flake template";
      };
    };
    defaultTemplate = self.templates.simple;
  };
}
