#! /bin/sh

set -e

run() {
  show_install_steps
  clone_repo
  install_nix
  install_direnv
  finish
}

show_install_steps() {
  echo "This setup script will perform the following operations:"
  echo
  echo "  1. Clone the Constructable repository to your home directory"
  echo "  2. Install nix on your system"
  echo "  3. Install direnv on your system and update shell startup config"
  echo
  echo "This script is idempotent. You can run it multiple times without any harm."
  echo
  echo "Press any key to continue..."
  read
}

clone_repo() {
  echo "Cloning CPM repository"

  cd $HOME
  git clone git@github.com:constructable-ai/cpm.git
  
  echo "Done"
  echo
}

install_nix() {
  echo "Installing nix"

  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  
  echo "Done"
  echo
}

install_direnv() {
  echo "Installing up direnv"

  cd $HOME/cpm
  nix profile install nixpkgs#direnv
  
  add_line_if_not_exists "$HOME/.zshrc" 'eval "$(direnv hook zsh)"'
  add_line_if_not_exists "$HOME/.bashrc" 'eval "$(direnv hook bash)"'

  cd $HOME/cpm
  nix profile install .#nix-direnv
  mkdir -p $HOME/.config/direnv
  add_line_if_not_exists "$HOME/.config/direnv/direnvrc" "source $HOME/.nix-profile/share/nix-direnv/direnvrc"
  
  direnv allow .

  echo "Done"
  echo
}

finish() {
  echo "Success! You must close this terminal to continue. Press enter to close the terminal..."
  read
  kill -9 $PPID
}

add_line_if_not_exists() {
  local file=$1
  local line=$2

  if [ ! -f "$file" ] || ! grep -Fxq "$line" "$file"; then
    echo "$line" >> "$file"
    echo "Added to $file: $line"
  fi
}


run
