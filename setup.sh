#!/usr/bin/env bash

echo "Installing dependencies..."
luarocks install fzy --local

echo "Installing dotfiles"
cd ~/.dotfiles/
stow --ignore=".git*|setup.sh" .
cd -
