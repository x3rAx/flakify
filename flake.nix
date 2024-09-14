{
  description = "My nix flake templates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} (
      {lib, ...}: {
        imports = [];

        systems = [
          "aarch64-linux"
          "x86_64-linux"

          "x86_64-darwin"
          "aarch64-darwin"
        ];

        perSystem = {
          config,
          pkgs,
          self',
          ...
        }: {
          devShells.default = pkgs.callPackage ./shell.nix {};
        };

        flake = {
          templates = {
            rust = {
              path = ./templates/rust;
              description = "nix flake new -t github:x3rAx/flakify#rust .";
            };
          };
        };
      }
    );
}
