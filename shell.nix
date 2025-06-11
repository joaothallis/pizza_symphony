{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.python3
    pkgs.python3Packages.numpy
  ];

  shellHook = ''
    echo "Nix shell for generating piano note WAV files"
    echo "Python version: $(python3 --version)"
    echo "NumPy version: $(python3 -c 'import numpy; print(numpy.__version__)')"
    echo "Run 'python generate_piano_notes.py' to generate WAV files"
  '';
}
