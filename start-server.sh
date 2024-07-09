#! /bin/zsh

cd $HOME/cpm

direnv allow .
eval "$(direnv export zsh)"

foreman start
