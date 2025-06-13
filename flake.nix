{
  description = "Nix templates";

  outputs = {self, ...}: {
    templates = {
      nix-rust-moonrepo = {
        path = ./nix-rust-moonrepo;
        description = "A template for Rust monorepos with Nix and moon";
      };
      cpp-meson = {
        path = ./cpp-meson;
        description = "A template for C++ development with meson";
      };
    };

    defaultTemplate = self.templates.cpp-meson;
  };
}
