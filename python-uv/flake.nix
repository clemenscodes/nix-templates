{
  description = "Pytest flake using uv2nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    uv2nix,
    pyproject-nix,
    pyproject-build-systems,
    ...
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
    };

    inherit (pkgs) lib;

    workspace = uv2nix.lib.workspace.loadWorkspace {workspaceRoot = ./.;};

    overlay = workspace.mkPyprojectOverlay {
      sourcePreference = "wheel";
    };

    python = pkgs.python312;

    pyprojectOverrides = final: prev: {
      testing = prev.testing.overrideAttrs (old: {
        passthru =
          old.passthru
          // {
            tests = let
              virtualenv = final.mkVirtualEnv "testing-pytest-env" {
                testing = ["test"];
              };
            in
              (old.tests or {})
              // {
                pytest = pkgs.stdenv.mkDerivation {
                  name = "${final.testing.name}-pytest";
                  inherit (final.testing) src;
                  nativeBuildInputs = [virtualenv];
                  dontConfigure = true;

                  buildPhase = ''
                    runHook preBuild
                    pytest --cov tests --cov-report html
                    runHook postBuild
                  '';

                  installPhase = ''
                    runHook preInstall
                    mv htmlcov $out
                    runHook postInstall
                  '';
                };
              };
          };
      });
    };

    pythonSet =
      (pkgs.callPackage pyproject-nix.build.packages {
        inherit python;
      }).overrideScope (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.default
          overlay
          pyprojectOverrides
        ]
      );
  in {
    checks = {
      ${system} = {
        inherit (pythonSet.testing.passthru.tests) pytest;
      };
    };

    packages.${system}.default = pythonSet.mkVirtualEnv "hello-world-env" workspace.deps.default;

    apps.${system} = {
      default = {
        type = "app";
        program = "${self.packages.x86_64-linux.default}/bin/hello";
        meta = {
          description = "Dummy python app using uv and nix";
        };
      };
    };

    devShells.${system} = {
      impure = pkgs.mkShell {
        packages = [
          python
          pkgs.uv
        ];
        env = {
          UV_PYTHON_DOWNLOADS = "never";
          UV_PYTHON = python.interpreter;
          LD_LIBRARY_PATH = lib.makeLibraryPath pkgs.pythonManylinuxPackages.manylinux1;
        };
        shellHook = ''
          unset PYTHONPATH
        '';
      };

      default = let
        editableOverlay = workspace.mkEditablePyprojectOverlay {
          root = "$REPO_ROOT";
          members = ["hello-world"];
        };

        editablePythonSet = pythonSet.overrideScope (
          lib.composeManyExtensions [
            editableOverlay

            (final: prev: {
              hello-world = prev.hello-world.overrideAttrs (old: {
                src = lib.fileset.toSource {
                  root = old.src;
                  fileset = lib.fileset.unions [
                    (old.src + "/pyproject.toml")
                    (old.src + "/README.md")
                    (old.src + "/src/hello_world/__init__.py")
                  ];
                };

                nativeBuildInputs =
                  old.nativeBuildInputs
                  ++ final.resolveBuildSystem {
                    editables = [];
                  };
              });
            })
          ]
        );

        virtualenv = editablePythonSet.mkVirtualEnv "hello-world-dev-env" workspace.deps.all;
      in
        pkgs.mkShell {
          packages = [
            virtualenv
            pkgs.uv
          ];

          env = {
            UV_NO_SYNC = "1";
            UV_PYTHON = "${virtualenv}/bin/python";
            UV_PYTHON_DOWNLOADS = "never";
          };

          shellHook = ''
            unset PYTHONPATH
            export REPO_ROOT=$(git rev-parse --show-toplevel)
          '';
        };
    };
  };
}
