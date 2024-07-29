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

  echo "Done"
  echo
}

start_server() {
  echo "Starting server"

  cd $HOME/cpm
  foreman start
}


run
