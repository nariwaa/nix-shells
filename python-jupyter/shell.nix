# made to work as best as possible with zed-editor

{ pkgs ? import <nixpkgs> {} }:

let
  python = pkgs.python312.override {
    packageOverrides = self: super: {
      pyzmq = super.pyzmq.overrideAttrs (old: {
        nativeBuildInputs = old.nativeBuildInputs or [] ++ [
          pkgs.pkg-config
        ];
        buildInputs = old.buildInputs or [] ++ [
          pkgs.zeromq
          pkgs.stdenv.cc.cc.lib
        ];
      });
    };
  };
  pythonPackages = python.pkgs;
in
pkgs.mkShell {
  buildInputs = [
    pkgs.zed-editor
    python
    pythonPackages.pip
    pythonPackages.virtualenv
    pkgs.zeromq
    pkgs.gcc
    pkgs.zlib
    pkgs.stdenv.cc.cc.lib
  ];

  # Critical environment variables
  LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zeromq}/lib";
  ZMQ_PREFIX = "${pkgs.zeromq}";
  CPPFLAGS = "-I${pkgs.zeromq}/include";
  LDFLAGS = "-L${pkgs.zeromq}/lib -L${pkgs.stdenv.cc.cc.lib}/lib";

  shellHook = ''
    echo -e "\033[33m[1/5] Initializing environment\033[0m"
    export PATH="${python}/bin:$PATH"

    # Clean previous virtual environment
    if [ -d ./.pythonlib/venv ]; then
      echo -e "\033[31mRemoving old virtual environment\033[0m"
      rm -rf ./.pythonlib/venv
    fi

    echo -e "\033[33m[2/5] Creating new virtual environment\033[0m"
    python -m venv ./.pythonlib/venv --system-site-packages
    source ./.pythonlib/venv/bin/activate

    # Re-apply critical environment variables after activation
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zeromq}/lib:$LD_LIBRARY_PATH"
    export ZMQ_PREFIX="${pkgs.zeromq}"
    export CPPFLAGS="-I${pkgs.zeromq}/include"
    export LDFLAGS="-L${pkgs.zeromq}/lib -L${pkgs.stdenv.cc.cc.lib}/lib"

    echo -e "\033[33m[3/5] Installing Python requirements\033[0m"
    pip install --no-cache-dir --force-reinstall -r requirements.txt

    echo -e "\033[33m[4/5] Configuring Jupyter kernel\033[0m"
    python -m ipykernel install --user --name=nix-venv --display-name="Nix Python 3.12"

    echo -e "\033[33m[5/5] Verifying installation\033[0m"
    if python -c "import zmq; print(f'ZMQ version: {zmq.zmq_version()}')"; then
      echo -e "\033[32mZMQ loaded successfully!\033[0m"
    else
      echo -e "\033[31mZMQ loading failed!\033[0m" >&2
      exit 1
    fi

    # Original setup tasks
    echo -e "\033[31mConfiguring ignore files...\033[0m"
    lineinfile() {
        local file="$1"
        local line="$2"

        [ ! -f "$file" ] && touch "$file"
        grep -q -F "$line" "$file" || {
            echo "$line" >> "$file"
            echo -e "\033[31m    Added '$line' to $file\033[0m"
        }
    }

    lineinfile ".telescopeignore" "./.pythonlib/"
    lineinfile ".gitignore" "./.pythonlib/"

    echo -e "\033[33m\nEnvironment ready! \033[0m"
  '';
}
