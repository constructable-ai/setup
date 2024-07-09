#! /bin/zsh

cd $HOME/cpm

direnv allow .
direnv reload

foreman start
