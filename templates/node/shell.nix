{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "nix-shell";

  packages = with pkgs; [
    bashInteractive

    nodejs
    pnpm
  ];
}

