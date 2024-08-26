#! /bin/zsh

set -e


run() {
  install_dependencies
  start_server
}

install_dependencies() {
  echo "Installing project dependencies"

  cd $HOME/cpm
  direnv allow .
  eval "$(direnv export zsh)"

  bun install

  echo "Done"
  echo
}

start_server() {
  echo "Starting server"

  cd $HOME/cpm
  bunx sst dev
}

run
