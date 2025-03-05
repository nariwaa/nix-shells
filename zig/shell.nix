{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    zig
  ];

  shellHook = ''
  '';
}
