{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "flakify";

  packages = with pkgs; [
    bashInteractive
    shellcheck
  ];
}

