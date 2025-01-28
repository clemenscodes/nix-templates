{
  description = "Nix templates";

  outputs = {self, ...}: {
    templates = {
      nix-rust-moonrepo = {
        path = ./nix-rust-moonrepo;
        description = "A template for Rust monorepos with Nix and moon";
      };
    };

    defaultTemplate = self.templates.rust;
  };
}
