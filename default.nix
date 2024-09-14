{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "flakify";
  version = "0.1.0";

  src = builtins.path {
    path = ./src;
    name = pname;
  };

  installPhase = ''
    mkdir -p $out/bin
    install -m 755 $src/flakify $out/bin
  '';
}
