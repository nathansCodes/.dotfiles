#!/usr/bin/env bash

echo "Installing dotfiles"
stow --ignore=".git*|setup.sh" .
cd -
