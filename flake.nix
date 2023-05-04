{
  outputs = { self }: {
    templates = {
      default.path = ./default;
      rust.path = ./rust;
      postgres.path = ./postgres;
    };
    defaultTemplate = self.templates.default;
  };
}
