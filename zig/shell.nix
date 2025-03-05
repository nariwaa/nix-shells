{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.zig
    pkgs.zls # zig language server
  ];

  shellHook = ''
  '';
}
