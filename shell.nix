{ pkgs ? import <nixpkgs> {} }:

let
  pythonPackages = pkgs.python312Packages;
in
pkgs.mkShell {
  buildInputs = [
    pkgs.python312
    pythonPackages.pip
    pythonPackages.virtualenv
  ];

  shellHook = ''
    # Create a virtual environment in ./.pythonlib if it doesn't exist
    if [ ! -d ./.pythonlib/venv ]; then
      python -m venv ./.pythonlib/venv
    fi

    # Activate the virtual environment
    source ./.pythonlib/venv/bin/activate

    # Install requirements
    pip install -r requirements.txt

    touch ".telescopeignore"
    echo "./pythonlib/" > ".telescopeignore/*" 
    echo "Done."
  '';
}
