#!/bin/sh

set -e

EFFECTIVE_USER_ID="$(id -u)"
if test "$EFFECTIVE_USER_ID" -eq 0; then
  printf "%s: permission denied\n" "${0##*/}" 1>&2
  exit 1
fi

unset PACKAGES

add_packages() {
  while test "$#" -gt 0; do
    PACKAGES="${PACKAGES:+$PACKAGES }\"$1\""
    shift 1
  done
}

install_packages() {
  eval set -- $PACKAGES
  #apt-get --no-install-recommends --assume-yes install "$@"
  printf "%s\n" "$@"
}

add_packages vim tmux git make                                   # terminal
add_packages virtualbox-guest-additions-iso virtualbox-qt        # virtual
add_packages bleachbit keepassx                                  # misc

install_packages
