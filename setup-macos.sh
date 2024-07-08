#!/bin/sh

run() {
  show_install_steps
  echo

  install_homebrew
  echo

  install_git
  echo

  install_zsh
  echo

  setup_ssh_keys
  echo
}

show_install_steps() {
  echo "This setup script will perform the following operations:"
  echo
  echo "  1. Install Homebrew"
  echo "  2. Install Git"
  echo "  3. Install Zsh and make it the default shell"
  echo "  4. Generate an SSH key if needed"
  echo
  echo "This script is idempotent. You can run it multiple times without any harm."
  echo
  echo "Press any key to continue..."
  read

  install_homebrew
  install_git
  install_zsh
  setup_ssh_keys
}

install_homebrew() {
  if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew is already installed."
  fi

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
}

install_git() {
  if ! command -v git &> /dev/null; then
    echo "Git not found. Installing Git..."
    brew install git
  else
    echo "Git is already installed."
  fi
}

install_zsh() {
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
}

setup_ssh_keys() {
  SSH_KEY="$HOME/.ssh/id_ed25519"

  if [ ! -f "$SSH_KEY" ]; then
    read -p "Enter your email address (this will be used to generate an SSH key): " email
    echo "SSH key not found. Generating a new SSH key..."
    ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY" -N ""
  else
    echo "SSH key already exists."
  fi

  eval "$(ssh-agent -s)"

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

  echo "The following SSH key has been copied to your clipboard. Please"
  echo "slack it to John so he can give you access to Constructable repos:"
  echo
  cat "$SSH_KEY.pub"
}

run
