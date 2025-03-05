{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.zig
    pkgs.zls # zig language server
  ];

  shellHook = ''
    echo -e "\033[31mCreating .telescopeignore and .gitignore if not done already...\033[0m"

    # Function to check if a line exists in a file
    lineinfile() {
        local file="$1"
        local line="$2"
        
        if [ ! -f "$file" ]; then
            touch "$file"
        fi
        
        if ! grep -q -F "$line" "$file"; then
            echo "$line" >> "$file"
            echo -e "\033[31m    Added '$line' to $file\033[0m"
        else
            echo -e "\033[31m    '$line' already exists in $file, doing nothing."
        fi
    }

    # telescope
    lineinfile ".telescopeignore" "./.pythonlib/"

    # gitignore
    lineinfile ".gitignore" ""
    lineinfile ".gitignore" "ig-cache/
    lineinfile ".gitignore" "ig-out/
    lineinfile ".gitignore" "uild/
    lineinfile ".gitignore" "uild-*/
    lineinfile ".gitignore" "ocgen_tmp/
    echo -e "\033[33m\nDone!\033[0m"
  '';
}
