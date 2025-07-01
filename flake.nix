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
          packages = {
            default = config.packages.flakify;
            flakify = pkgs.callPackage ./default.nix {};
          };

          devShells.default = pkgs.callPackage ./shell.nix {};
        };

        flake = {
          overlays.default = final: _prev: {flakify = final.callPackage ./default.nix {};};

          templates = let
            mkTemplates = builtins.foldl' (collect: name: let
              flake = import (./templates + "/${name}/flake.nix");
            in
              collect
              // {
                "${name}" = {
                  path = ./templates + "/${name}";
                  description = flake.description + "\n-> nix flake new -t github:x3rAx/flakify#${name} .";
                };
              }) {};
            templateDirs = builtins.attrNames (lib.filterAttrs (name: type: type == "directory" && !lib.hasPrefix "." name) (builtins.readDir ./templates));
          in
            mkTemplates templateDirs;
        };
      }
    );
}
