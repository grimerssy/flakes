{
  outputs = { self }: {
    templates = {
      rust.path = ./rust;
      postgres.path = ./postgres;
    };
  };
}
