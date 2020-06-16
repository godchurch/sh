#!/bin/sh

set -ex
GIT="https://github.com"
GIT_PROFILE="$GIT/godchurch"
DEST="$HOME/Documents/git"
REPOS="base-ubuntu dotfiles random sh vm"
command -v git > /dev/null
test -d "$DEST" || mkdir -p  "$DEST"
for REPO in $REPOS; do git clone "$GIT_PROFILE/$REPO.git" "$DEST/$REPO"; done
