{
  description = "A Python Flake (with `uv`)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      perSystem = {pkgs, ...}: {
        devShells.default = pkgs.mkShell {
          name = "nix-python-shell";

          packages = with pkgs; [
            bashInteractive

            python3
            uv

            just # Command runner for `justfile`
          ];

          shellHook = ''
            ${
              let
                # Add system libraries needed at runtime (e.g. for packages with C
                # extensions). Common choices:
                #   pkgs.stdenv.cc.cc.lib  (libstdc++)
                #   pkgs.zlib
                systemLibs = [];
              in
                pkgs.lib.optionalString (systemLibs != []) ''
                  export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath systemLibs}:$LD_LIBRARY_PATH"
                ''
            }

            echo "🐍 Python development environment loaded"
          '';
        };
      };
    };
}
