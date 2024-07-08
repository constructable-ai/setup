#! /bin/sh

set -e

run() {
  clone_repo
  install_nix
  install_direnv
}

clone_repo() {
  echo "Cloning CPM repository"

  cd $HOME
  git clone git@github.com:constructable-ai/cpm.git
  cd $HOME/cpm
  
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

  nix profile install nixpkgs#direnv
  
  add_line_if_not_exists "$HOME/.zshrc" 'eval "$(direnv hook zsh)"'
  add_line_if_not_exists "$HOME/.bashrc" 'eval "$(direnv hook bash)"'

  nix profile install .#nix-direnv
  mkdir -p $HOME/.config/direnv
  add_line_if_not_exists "$HOME/.config/direnv/direnvrc" "source $HOME/.nix-profile/share/nix-direnv/direnvrc"
  
  direnv allow .

  echo "Done"
  echo
}

add_line_if_not_exists() {
  local file=$1
  local line=$2

  if [ -f "$file" ]; then
    if ! grep -Fxq "$line" "$file"; then
      echo "$line" >> "$file"
      echo "Added to $file: $line"
    fi
  fi
}

run
