{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
    nix-filter = {
      url = "github:numtide/nix-filter";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    nix-filter,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem = {system, ...}: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        packages = {
          default = pkgs.callPackage ./package.nix {
            pname = "hello";
            version = "0.1.0";
            src = nix-filter.lib {
              root = ./.;
              include = [
                "meson.build"
                "src"
                "include"
                "tests"
              ];
            };
          };
        };

        devShells = {
          default = pkgs.callPackage ./shell.nix {};
        };

        formatter = pkgs.alejandra;
      };
    };
}
