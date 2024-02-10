#!/usr/bin/env bash

cd ~/.dotfiles/
stow --ignore=".gitmodules|setup.sh" .
