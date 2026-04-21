{
  description = "A Rust Flake (with fenix and Crane)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };

    # Rust toolchains
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Library for building Cargo projects
    crane.url = "github:ipetkov/crane";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      perSystem = {
        config,
        inputs',
        pkgs,
        ...
      }: let
        fenix = inputs'.fenix.packages;

        fenix-shell-profile = fenix.stable;
        fenix-build-toolchain = fenix.stable.minimalToolchain;

        craneLib = (inputs.crane.mkLib pkgs).overrideToolchain fenix-build-toolchain;

        cleanCargoSource = src:
          pkgs.lib.cleanSourceWith {
            inherit src;
            filter = path: type: let
              isCargoSource = craneLib.filterCargoSources path type;
              isPestFile = type == "regular" && (builtins.match ".*\.pest" path) != null;
            in
              isCargoSource || isPestFile;
          };
      in {
        devShells.default = pkgs.mkShell {
          name = "nix-rust-shell";

          packages = with pkgs; [
            bashInteractive

            (fenix-shell-profile.withComponents [
              "cargo"
              "clippy"
              "rust-analyzer"
              "rust-src"
              "rustfmt"
            ])

            bacon # CLI test runner
            cargo-watch

            #openssl.dev
            #pkgconfig # Required to find openssl
            #lldb # Install lldb with `lldb-dap` (aka `lldb-vscode`)

            just # Command runner for `justfile`
          ];

          shellHook = ''
            # If OpenSSL can not be found, uncomment the following line
            #export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [pkgs.openssl]}:$LD_LIBRARY_PATH"

            echo "🦀 Rust development environment loaded"
          '';
        };

        packages = {
          default = config.packages.my-app;
          my-app = craneLib.buildPackage {src = cleanCargoSource ./.;};
        };
      };

      flake.overlays = {
        default = inputs.self.overlays.my-app;
        my-app = _final: prev: {
          my-app = inputs.self.packages.${prev.system}.my-app;
        };
      };
    };
}
