{
  description = "A collection of flake templates";

  outputs = { self }: {
    templates = {
      simple = {
        path = ./simple;
        description = "Hello world of flakes";
      };
    };
    defaultTemplate = self.templates.simple;
  };
}
