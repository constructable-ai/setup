#!/bin/sh

set -e

SSH_KEY="$HOME/.ssh/id_ed25519"

run() {
  show_install_steps
  install_homebrew
  install_utilities
  setup_1password
  install_zsh
  setup_ssh_keys
  add_ssh_keys
  clone_repo
  install_nix
  install_direnv

  finish
}

show_install_steps() {
  echo "This setup script will perform the following operations:"
  echo
  echo "  1. Install Homebrew"
  echo "  2. Install required command line utilities"
  echo "  3. Setup 1Password and 1Password CLI integration"
  echo "  4. Setup a development tunnel so you can access the server from a public URL"
  echo "  5. Install Zsh and make it the default shell"
  echo "  6. Generate an SSH key if needed"
  echo "  7. Add the SSH key to Github if needed"
  echo "  8. Clone the Constructable repository to your home directory"
  echo "  9. Install nix on your system"
  echo "  10. Install direnv on your system and update shell startup config"
  echo
  echo "This script is idempotent. You can run it multiple times without any harm."
  echo
  echo "Press any key to continue..."
  read
}

install_homebrew() {
  echo "Installing Homebrew"

  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew is already installed."
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Add Homebrew to PATH for interactive shells
  if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zshrc; then
    echo "Adding Homebrew to PATH in .zshrc..."
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "Homebrew PATH is already configured in .zshrc."
  fi

  # Optionally add Homebrew to PATH for login shells
  if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile; then
    echo "Adding Homebrew to PATH in .zprofile..."
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  else
    echo "Homebrew PATH is already configured in .zprofile."
  fi

  echo "Done"
  echo
}

install_utilities() {
  echo "Installing utilities"

  if [ ! -d "/Applications/1Password.app" ]; then
    echo "1Password is not installed. Installing via Homebrew..."
    brew install --cask 1password
  else
    echo "1Password is already installed."
  fi

  brew install git gh jq 1password-cli

  echo "Done"
  echo
}

setup_1password() {
  echo "Setting up 1Password:"
  echo "1. Login to 1Password with your Constructable credentials"
  echo "2. Under 1Password > Settings > Developer, ensure that Enable 1Password CLI is checked"
  echo "3. Close 1Password"
  open /Applications/1Password.app

  echo "Press any key to continue"
  read

  echo "Signing in to the 1Password Constructable vault"
  op signin --account constructable.1password.com

  echo "Done"
  echo
}

install_zsh() {
  echo "Installing Zsh"

  if ! command -v zsh &> /dev/null; then
    echo "Zsh not found. Installing Zsh..."
    brew install zsh
  else
    echo "Zsh is already installed."
  fi

  # Make sure zsh is the default shell
  if [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/local/bin/zsh" ] && [ "$SHELL" != "/opt/homebrew/bin/zsh" ]; then
    echo "Setting Zsh as the default shell..."
    chsh -s "$(which zsh)"
  else
    echo "Zsh is already the default shell."
  fi

  echo "Done"
  echo
}

setup_ssh_keys() {
  echo "Setting up SSH keys"

  if [ ! -f "$SSH_KEY" ]; then
    read -p "Enter your Constructable email address (this will be used to generate an SSH key): " email
    echo "SSH key not found. Generating a new SSH key..."
    ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY" -N ""
  else
    echo "SSH key already exists."
  fi

  if [ -z "$SSH_AUTH_SOCK" ] || ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
  else
    echo "Using existing ssh-agent."
  fi

  if ! ssh-add -L | grep -q "$(cat $SSH_KEY.pub)"; then
    echo "Adding SSH key to the SSH agent..."
    ssh-add "$SSH_KEY"
  else
    echo "SSH key is already added to the SSH agent."
  fi

  echo

  echo "Copying SSH key to clipboard..."
  pbcopy < "$SSH_KEY.pub"
  echo

  echo "The following SSH key has been copied to your clipboard. Please visit"
  echo 'https://github.com/settings/keys and add a new SSH key by clicking "New SSH Key"'
  echo
  echo "Your SSH key:"
  cat "$SSH_KEY.pub"
  echo
}

add_ssh_keys() {
  echo "Adding SSH key to Github"

  local title="$(hostname)"

  gh auth login --hostname github.com --git-protocol ssh --web

  echo "Done"
  echo
}

clone_repo() {
  echo "Cloning CPM repository"

  cd $HOME
  if [ ! -d "cpm" ]; then
    git clone git@github.com:constructable-ai/cpm.git
    echo "CPM repository cloned successfully."
  else
    echo "CPM repository already exists. Skipping clone."
  fi
  
  echo "Done"
  echo
}

install_nix() {
  echo "Installing nix"

  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  
  echo "Done"
  echo
}

install_direnv() {
  echo "Installing direnv"

  cd $HOME/cpm
  nix profile install nixpkgs#direnv  
  add_line_if_not_exists "$HOME/.zshrc" 'eval "$(direnv hook zsh)"'

  nix profile install .#nix-direnv
  mkdir -p $HOME/.config/direnv
  add_line_if_not_exists "$HOME/.config/direnv/direnvrc" "source $HOME/.nix-profile/share/nix-direnv/direnvrc"

  echo "Done"
  echo
}

finish() {
  # Replace the user's terminal with a Zsh and finish configuring direnv for the project
  exec /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/constructable-ai/setup/main/start-server.sh); exec zsh"
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
