#!/bin/bash

PROFILE=${1}

if [ x${PROFILE} = x ]; then
	echo "Usage: $0 [profile]"
	exit 1
fi

if [ ! -e "profiles/${PROFILE}.conf" ]; then
	echo "Unknown profile: ${PROFILE}"
	exit 1
fi

OSCODE=`lsb_release -c | awk '{print $2}'`
if [ x${OSCODE} = x ]; then
	echo "Cannot determine OS codename";
	exit 1
fi

REMOVE_KEYBOARD_PROMPTS="--keyboard us --locale en_US.UTF-8"
OPTS="--keyring ./debian-archive-keyring.gpg ${REMOVE_KEYBOARD_PROMPTS}"
if [ `id -u` -eq 0 ]; then
	OPTS="${OPTS} --force-root"
fi

if [ ! -f "./debian-archive-keyring.gpg" ]; then
	wget http://ftp.de.debian.org/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2019.1_all.deb
	rm -rf keys 2>&1 || true
	mkdir keys
	dpkg-deb -xv *.deb keys/
	cp ./keys/usr/share/keyrings/debian-archive-keyring.gpg .
	rm *.deb
	rm -rf keys
fi
if [ ! -d ./images ]; then mkdir images; fi

time build-simple-cdd --conf profiles/${PROFILE}.conf ${OPTS} \
	--dist ${OSCODE} --logfile images/last-build.log
