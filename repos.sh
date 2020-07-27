#!/bin/sh

set -ex

command -v git > /dev/null

test -d "$HOME/Documents/git" || mkdir -p  "$HOME/Documents/git"
for i in base-ubuntu dotfiles random sh vm; do
  git clone "https://github.com/godchurch/$i.git" "$HOME/Documents/git/$i"
done
