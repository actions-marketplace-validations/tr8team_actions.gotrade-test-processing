{
  inputs = {
    # util
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    # registry
    nixpkgs.url = "nixpkgs/9418167277f665de6f4a29f414d438cf39c55b9e";
    nixpkgs-aug-01-23.url = "nixpkgs/9418167277f665de6f4a29f414d438cf39c55b9e";
    atomipkgs.url = "github:kirinnee/test-nix-repo/v18.0.1";
    atomicpkgs-classic.url = "github:kirinnee/test-nix-repo/classic";
  };
  outputs =
    { self

      # utils
    , flake-utils
    , treefmt-nix
    , pre-commit-hooks

      # registries
    , atomipkgs
    , atomicpkgs-classic
    , nixpkgs
    , nixpkgs-aug-01-23

    } @inputs:
    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        pkgs-aug-01-23 = nixpkgs-aug-01-23.legacyPackages.${system};
        atomi = atomipkgs.packages.${system};
        atomi_classic = atomicpkgs-classic.packages.${system};
        pre-commit-lib = pre-commit-hooks.lib.${system};
      in
      let
        out = rec {
          pre-commit = import ./nix/pre-commit.nix {
            inherit pre-commit-lib formatter packages;
          };
          formatter = import ./nix/fmt.nix {
            inherit treefmt-nix pkgs;
          };
          packages = import ./nix/packages.nix {
            inherit pkgs atomi atomi_classic pkgs-aug-01-23;
          };
          env = import ./nix/env.nix {
            inherit pkgs packages;
          };
          devShells = import ./nix/shells.nix {
            inherit pkgs env packages;
            shellHook = checks.pre-commit-check.shellHook;
          };
          checks = {
            pre-commit-check = pre-commit;
            format = formatter;
          };
        };
      in
      with out;
      {
        inherit checks formatter packages devShells;
      }
      );
}
