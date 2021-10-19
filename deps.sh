#!/bin/sh

if test `id -u` -ne 0; then
	command -v sudo > /dev/null && exec sudo "$0" "$@"
	printf 'E: Permission denied\n' >&2; exit 1
fi

exec apt-get -y install \
	vim \
	curl \
	git \
	make \
	tmux \
	qemu-system-x86 \
	libvirt-daemon \
	libvirt-clients \
	bridge-utils \
	virtualbox \
	virtualbox-qt \
	virtualbox-guest-additions-iso \
	keepassxc \
	bleachbit
